From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2 2/2] net: sched: cls_u32 changes to knode
 must appear atomic to readers
Date: Sat, 20 Sep 2014 18:20:50 -0700
Message-ID: <1411262450.26859.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140920045003.9869.16851.stgit@nitbit.x32>
	 <20140920045031.9869.76112.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:44922 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaIUBUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 21:20:52 -0400
Received: by mail-pa0-f50.google.com with SMTP id rd3so760516pab.9
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:20:52 -0700 (PDT)
In-Reply-To: <20140920045031.9869.76112.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 21:50 -0700, John Fastabend wrote:
> Changes to the cls_u32 classifier must appear atomic to the
> readers. Before this patch if a change is requested for both
> the exts and ifindex, first the ifindex is updated then the
> exts with tcf_exts_change(). This opens a small window where
> a reader can have a exts chain with an incorrect ifindex. This
> violates the the RCU semantics.

> CC: Eric Dumazet <edumazet@google.com>
> CC: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_u32.c |  135 ++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 126 insertions(+), 9 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
