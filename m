From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: remove delay at device dismantle
Date: Wed, 22 Aug 2012 21:50:54 -0700 (PDT)
Message-ID: <20120822.215054.1560262447672200871.davem@davemloft.net>
References: <1345691986.5904.40.camel@edumazet-glaptop>
	<5035B27F.9060002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, maheshb@google.com,
	therbert@google.com, ebiederm@xmission.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33009 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab2HWEu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 00:50:57 -0400
In-Reply-To: <5035B27F.9060002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Thu, 23 Aug 2012 12:33:03 +0800

> 于 2012年08月23日 11:19, Eric Dumazet 写道:
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> I noticed extra one second delay in device dismantle, tracked down to
>> a call to dst_dev_event() while some call_rcu() are still in RCU queues.
>> 
>> These call_rcu() were posted by rt_free(struct rtable *rt) calls.
>> 
>> We then wait a little (but one second) in netdev_wait_allrefs() before
>> kicking again NETDEV_UNREGISTER.
>> 
>> As the call_rcu() are now completed, dst_dev_event() can do the needed
>> device swap on busy dst.
>> 
>> To solve this problem, add a new NETDEV_UNREGISTER_FINAL, called
>> after a rcu_barrier(), but outside of RTNL lock.
>> 
>> Use NETDEV_UNREGISTER_FINAL with care !
>> 
>> Change dst_dev_event() handler to react to NETDEV_UNREGISTER_FINAL
>> 
>> Also remove NETDEV_UNREGISTER_BATCH, as its not used anymore after
>> IP cache removal.
>> 
>> With help from Gao feng
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Tom Herbert <therbert@google.com>
>> Cc: Mahesh Bandewar <maheshb@google.com>
>> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
>> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> 
> looks good to me, the lockdep warning message disappeared.

Applied, thanks everyone.
