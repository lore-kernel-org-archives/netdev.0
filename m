From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix RCU sparse error
Date: Tue, 09 Dec 2014 22:20:33 -0500 (EST)
Message-ID: <20141209.222033.1844730823231202072.davem@davemloft.net>
References: <1418180407-1847-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, kbuild-all@01.org, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755310AbaLJERq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 23:17:46 -0500
In-Reply-To: <1418180407-1847-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 10 Dec 2014 11:00:07 +0800

> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> index aa79b3c..866d9c9 100644
> --- a/include/linux/rculist.h
> +++ b/include/linux/rculist.h
> @@ -549,8 +549,8 @@ static inline void hlist_add_behind_rcu(struct hlist_node *n,
>   */
>  #define hlist_for_each_entry_from_rcu(pos, member)			\
>  	for (; pos;							\
> -	     pos = hlist_entry_safe(rcu_dereference((pos)->member.next),\
> -			typeof(*(pos)), member))
> +	     pos = hlist_entry_safe(rcu_dereference_raw(hlist_next_rcu( \
> +			&(pos)->member)), typeof(*(pos)), member))
>  
>  #endif	/* __KERNEL__ */
>  #endif

This needs to go via another route, perhaps the RCU maintainer.
