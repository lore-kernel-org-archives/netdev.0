From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/15] net: introduce upper device lists
Date: Sun, 30 Dec 2012 10:53:38 +0100
Message-ID: <20121230095338.GC1575@minipsycho.orion>
References: <1356777522-19652-1-git-send-email-jiri@resnulli.us>
 <1356777522-19652-2-git-send-email-jiri@resnulli.us>
 <20121229.153101.676681277388952344.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:51612 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab2L3Jxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 04:53:43 -0500
Received: by mail-ea0-f172.google.com with SMTP id a1so4946240eaa.3
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 01:53:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121229.153101.676681277388952344.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Dec 30, 2012 at 12:31:01AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Sat, 29 Dec 2012 11:38:28 +0100
>
>> +	/*
>> +	 * To prevent loops, check if dev is not upper device to upper_dev.
>> +	 */
>
>Please use:
>
>	/* To prevent loops, check if dev is not upper device to upper_dev.  */

fixed

>
>> +/**
>> + * netdev_upper_free_rcu - Frees a upper device list item via the RCU pointer
>> + * @entry: the entry's RCU field
>> + *
>> + * This function is designed to be used as a callback to the call_rcu()
>> + * function so that the memory allocated to the netdev upper device list item
>> + * can be released safely.
>> + */
>> +static void netdev_upper_free_rcu(struct rcu_head *entry)
>> +{
>> +	struct netdev_upper *upper;
>> +
>> +	upper = container_of(entry, struct netdev_upper, rcu);
>> +	kfree(upper);
>> +}
>
>Please use kfree_rcu().

fixed

>
>Also, since __netdev_has_upper_dev() modifies &search_list inside
>of the list traversal loop, I think you really need to use
>list_for_each_entry_safe() even though you always append to the
>tail of &search_list.

Hmm, I do not believe that list_for_each_entry_safe() would work correctly
here. In case that the current iterator is at the very end of
the list and now other items are added, list_for_each_entry_safe() would
remember that next is head and the newly added items would not be
processed. list_for_each_entry() works just fine in any case I can
imagine. Note that no items are removed during the iteration.
Am I missing something?

Thanks!

Jiri
