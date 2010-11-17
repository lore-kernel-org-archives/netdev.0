From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH v3] filter: Optimize instruction revalidation code.
Date: Wed, 17 Nov 2010 17:06:10 +0900
Message-ID: <201011170806.oAH86AdI013337@www262.sakura.ne.jp>
References: <20101110.102129.112602843.davem@davemloft.net> <1289414024.2469.20.camel@edumazet-laptop> <20101110.103807.39173013.davem@davemloft.net> <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp> <1289915053.5372.183.camel@edumazet-laptop> <201011162331.CGH00026.OFOSFVMFQtLHOJ@I-love.SAKURA.ne.jp> <1289925055.5372.484.camel@edumazet-laptop> <201011170119.oAH1JpES011121@www262.sakura.ne.jp> <1289980137.2732.280.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: mjt@tls.msk.ru, davem@davemloft.net, drosenberg@vsecurity.com,
	hagen@jauu.net, xiaosuo@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:49589 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758033Ab0KQIG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 03:06:26 -0500
In-Reply-To: <1289980137.2732.280.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> > > But how about this:
> > > 
> > > enum {
> > >         BPF_S_RET_K = 1,
> > 
> > If BPF_S_* are only for kernel internal use, I think we don't need to translate
> > from the beginning because only net/core/filter.c uses BPF_S_*.
> > 
> > BPF_S_* are exposed to userspace via /usr/include/linux/filter.h since 2.6.36.
> > Is it no problem to change?
> 
> No problem, and Changli posted patch to move them to net/core/filter.c
> anyway.

> Please repost it when Changli patch is accepted by David 
> (if accepted :)), to get rid of the "+ 1"

But if Changli's patch is accepted, we can remove BPF_S_* like below.

 	switch (fentry->code) {
-	case BPF_S_ALU_ADD_X:
+	case BPF_ALU|BPF_ADD|BPF_X: /* BPF_S_ALU_ADD_X */
 		A += X;
 		continue;
-	case BPF_S_ALU_ADD_K:
+	case BPF_ALU|BPF_ADD|BPF_K: /* BPF_S_ALU_ADD_K */
 		A += f_k;
 		continue;
-	case BPF_S_ALU_SUB_X:
+	case BPF_ALU|BPF_SUB|BPF_X: /* BPF_S_ALU_SUB_X */
 		A -= X;
 		continue;
-	case BPF_S_ALU_SUB_K:
+	case BPF_ALU|BPF_SUB|BPF_K: /* BPF_S_ALU_SUB_K */
 		A -= f_k;
 		continue;

If compilers can generate better code for continuous case values
than discontinuous case values, then keeping BPF_S_* makes sense.
