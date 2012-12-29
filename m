From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 01/15] net: introduce upper device lists
Date: Sat, 29 Dec 2012 15:31:01 -0800 (PST)
Message-ID: <20121229.153101.676681277388952344.davem@davemloft.net>
References: <1356777522-19652-1-git-send-email-jiri@resnulli.us>
	<1356777522-19652-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753334Ab2L2XbG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 18:31:06 -0500
In-Reply-To: <1356777522-19652-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sat, 29 Dec 2012 11:38:28 +0100

> +	/*
> +	 * To prevent loops, check if dev is not upper device to upper_dev.
> +	 */

Please use:

	/* To prevent loops, check if dev is not upper device to upper_dev.  */

> +/**
> + * netdev_upper_free_rcu - Frees a upper device list item via the RCU pointer
> + * @entry: the entry's RCU field
> + *
> + * This function is designed to be used as a callback to the call_rcu()
> + * function so that the memory allocated to the netdev upper device list item
> + * can be released safely.
> + */
> +static void netdev_upper_free_rcu(struct rcu_head *entry)
> +{
> +	struct netdev_upper *upper;
> +
> +	upper = container_of(entry, struct netdev_upper, rcu);
> +	kfree(upper);
> +}

Please use kfree_rcu().

Also, since __netdev_has_upper_dev() modifies &search_list inside
of the list traversal loop, I think you really need to use
list_for_each_entry_safe() even though you always append to the
tail of &search_list.
