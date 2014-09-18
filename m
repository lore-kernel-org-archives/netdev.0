From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 2/2] net: sched: cls_u32 changes to knode must
 appear atomic to readers
Date: Thu, 18 Sep 2014 07:38:13 -0400
Message-ID: <541AC425.2090300@mojatatu.com>
References: <20140917191131.20529.91136.stgit@nitbit.x32> <20140917191202.20529.87231.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:58094 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756683AbaIRLiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 07:38:19 -0400
Received: by mail-ie0-f179.google.com with SMTP id rl12so898932iec.24
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 04:38:18 -0700 (PDT)
In-Reply-To: <20140917191202.20529.87231.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/17/14 15:12, John Fastabend wrote:
> Changes to the cls_u32 classifier must appear atomic to the
> readers. Before this patch if a change is requested for both
> the exts and ifindex, first the ifindex is updated then the
> exts with tcf_exts_change(). This opens a small window where
> a reader can have a exts chain with an incorrect ifindex. This
> violates the the RCU semantics.
>
> Here we resolve this by always passing u32_set_parms() a copy
> of the tc_u_knode to work on and then inserting it into the hash
> table after the updates have been successfully applied.
>
> Tested with the following short script:
>

>
> #tc filter add dev p3p2 parent 8001:0 protocol ip prio 99 handle 1: \
> 	       u32 divisor 256
>
> #tc filter add dev p3p2 parent 8001:0 protocol ip prio 99 \
> 	       u32 link 1: hashkey mask ffffff00 at 12    \
> 	       match ip src 192.168.8.0/2
>
> #tc filter add dev p3p2 parent 8001:0 protocol ip prio 102    \
> 	       handle 1::10 u32 classid 1:2 ht 1: 	      \
> 	       match ip src 192.168.8.0/8 match ip tos 0x0a 1e
>
> #tc filter change dev p3p2 parent 8001:0 protocol ip prio 102 \
> 		 handle 1::10 u32 classid 1:2 ht 1:        \
> 		 match ip src 1.1.0.0/8 match ip tos 0x0b 1e
>
> CC: Eric Dumazet <edumazet@google.com>
> CC: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>


Looks good to me.
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
