From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 15/18] flag parameters: NONBLOCK in timerfd_create
Date: Tue, 6 May 2008 15:45:21 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805061542250.25162@alien.or.mcafeemobile.com>
References: <200805062118.m46LI72i004086@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:38041 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755057AbYEFWpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 18:45:22 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S28B3C6> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Tue, 6 May 2008 18:45:21 -0400
In-Reply-To: <200805062118.m46LI72i004086@devserv.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 6 May 2008, Ulrich Drepper wrote:

> diff --git a/fs/timerfd.c b/fs/timerfd.c
> index c6ef5e3..75d44ef 100644
> --- a/fs/timerfd.c
> +++ b/fs/timerfd.c
> @@ -184,7 +184,7 @@ asmlinkage long sys_timerfd_create(int clockid, int flags)
>  	int ufd;
>  	struct timerfd_ctx *ctx;
>  
> -	if (flags & ~TFD_CLOEXEC)
> +	if (flags & ~(TFD_CLOEXEC | TFD_NONBLOCK))
>  		return -EINVAL;
>  	if (clockid != CLOCK_MONOTONIC &&
>  	    clockid != CLOCK_REALTIME)
> @@ -199,7 +199,7 @@ asmlinkage long sys_timerfd_create(int clockid, int flags)
>  	hrtimer_init(&ctx->tmr, clockid, HRTIMER_MODE_ABS);
>  
>  	ufd = anon_inode_getfd("[timerfd]", &timerfd_fops, ctx,
> -			       flags & O_CLOEXEC);
> +			       flags & (O_CLOEXEC | O_NONBLOCK));
>  	if (ufd < 0)
>  		kfree(ctx);

This is perfectly fine for me. Since the flags space for these new 
syscalls is almost empty, it makes perfect sense to just map them to the 
original O_* flags.


Acked-by: Davide Libenzi <davidel@xmailserver.org>

(for the whole serie)



- Davide


