From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Mon, 9 Feb 2009 07:44:56 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0902090740100.3048@localhost.localdomain>
References: <b6a2187b0902050641h7943816ds26275a320e724440@mail.gmail.com> <20090206031025.GA3281@gondor.apana.org.au> <b6a2187b0902052139p3be2f321ucd900cc5346bff8c@mail.gmail.com> <20090206054541.GA4954@gondor.apana.org.au> <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com>
 <20090209055848.GA3889@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Chua <jeff.chua.linux@gmail.com>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47907 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753940AbZBIPqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 10:46:04 -0500
In-Reply-To: <20090209055848.GA3889@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 9 Feb 2009, Herbert Xu wrote:
> 
> Then the problem isn't my patch at all.  My patch only affects
> the side sending the urgent data, according to your straces, rlogin
> is only receiving urgent data, not sending it.  So the patch cannot
> have an affect.

The trace is incolclusive about that - just look at it. It's not following 
threads/children etc, so it's missing all the relevant pieces.

Which you should have realized, Herbert, since you had the knowledge that 
your patch _DOES_ make a difference, enough to bisect to it, and enough 
to see that reverting it changes behaviour.

Why are you arguing against facts?

>From the trace:

	clone(child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7d81918) = 6433
	rt_sigaction(SIGURG, {0x80491d0, [URG], SA_RESTART}, {SIG_DFL}, 8) = 0
	rt_sigaction(SIGUSR1, {0x8048de0, [USR1], SA_RESTART}, {SIG_DFL}, 8) = 0
	rt_sigprocmask(SIG_SETMASK, [], [USR1 URG], 8) = 0
	--- SIGURG (Urgent I/O condition) @ 0 (0) ---
	kill(6433, SIGURG)                      = 0

IOW, the trace isn't saying anything at all, because all the real work 
probably got done in that child process.

> No you're still stracing rlogin, which in this case is the receiver
> of the urgent data.  Please strace the sending side, which would be
> presumably be rlogind in this case.

Herbert, how sure are you that there is no URG data on that side?

You clearly spent _zero_ time actually looking at the trace, so...

		Linus
