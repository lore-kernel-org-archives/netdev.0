From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Remove useless secid field from xfrm_audit.
Date: Tue, 22 Apr 2014 14:02:56 +0200
Message-ID: <20140422120256.GT32371@secunet.com>
References: <201404190100.IJG17653.VOSHJMtFQFOLOF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <jmlatten@linux.vnet.ibm.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50025 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932228AbaDVMDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:03:05 -0400
Content-Disposition: inline
In-Reply-To: <201404190100.IJG17653.VOSHJMtFQFOLOF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 19, 2014 at 01:00:27AM +0900, Tetsuo Handa wrote:
> >From 049fe797638a75b902b5c7bb845f6320bc0b47f6 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 18 Apr 2014 16:23:46 +0900
> Subject: [PATCH] xfrm: Remove useless secid field from xfrm_audit.
> 
> It seems to me that commit ab5f5e8b "[XFRM]: xfrm audit calls" is doing
> something strange at xfrm_audit_helper_usrinfo().
> If secid != 0 && security_secid_to_secctx(secid) != 0, the caller calls
> audit_log_task_context() which basically does
> secid != 0 && security_secid_to_secctx(secid) == 0 case
> except that secid is obtained from current thread's context.
> 
> Oh, what happens if secid passed to xfrm_audit_helper_usrinfo() was
> obtained from other thread's context? It might audit current thread's
> context rather than other thread's context if security_secid_to_secctx()
> in xfrm_audit_helper_usrinfo() failed for some reason.
> 
> Then, are all the caller of xfrm_audit_helper_usrinfo() passing either
> secid obtained from current thread's context or secid == 0?
> It seems to me that they are.
> 
> If I didn't miss something, we don't need to pass secid to
> xfrm_audit_helper_usrinfo() because audit_log_task_context() will
> obtain secid from current thread's context.

Yes, looks like that.

Applied to the ipsec-next tree.

Thanks!
