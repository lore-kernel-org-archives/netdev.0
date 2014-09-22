From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 2/2] net: sched: cls_u32 changes to knode
 must appear atomic to readers
Date: Mon, 22 Sep 2014 16:00:11 -0400 (EDT)
Message-ID: <20140922.160011.2111690808287706789.davem@davemloft.net>
References: <20140920045003.9869.16851.stgit@nitbit.x32>
	<20140920045031.9869.76112.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416AbaIVUAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 16:00:15 -0400
In-Reply-To: <20140920045031.9869.76112.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 19 Sep 2014 21:50:34 -0700

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
 ...
> CC: Eric Dumazet <edumazet@google.com>
> CC: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
