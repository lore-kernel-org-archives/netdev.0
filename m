From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Tue, 10 Feb 2009 08:17:37 +1100
Message-ID: <20090209211737.GA13831@gondor.apana.org.au>
References: <b6a2187b0902050641h7943816ds26275a320e724440@mail.gmail.com> <20090206031025.GA3281@gondor.apana.org.au> <b6a2187b0902052139p3be2f321ucd900cc5346bff8c@mail.gmail.com> <20090206054541.GA4954@gondor.apana.org.au> <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com> <20090209055848.GA3889@gondor.apana.org.au> <alpine.LFD.2.00.0902090740100.3048@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Chua <jeff.chua.linux@gmail.com>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33151 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755621AbZBIVSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 16:18:03 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0902090740100.3048@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2009 at 07:44:56AM -0800, Linus Torvalds wrote:
>
> The trace is incolclusive about that - just look at it. It's not following 
> threads/children etc, so it's missing all the relevant pieces.
> 
> Which you should have realized, Herbert, since you had the knowledge that 
> your patch _DOES_ make a difference, enough to bisect to it, and enough 
> to see that reverting it changes behaviour.
> 
> Why are you arguing against facts?
> 
> >From the trace:
> 
> 	clone(child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7d81918) = 6433
> 	rt_sigaction(SIGURG, {0x80491d0, [URG], SA_RESTART}, {SIG_DFL}, 8) = 0
> 	rt_sigaction(SIGUSR1, {0x8048de0, [USR1], SA_RESTART}, {SIG_DFL}, 8) = 0
> 	rt_sigprocmask(SIG_SETMASK, [], [USR1 URG], 8) = 0
> 	--- SIGURG (Urgent I/O condition) @ 0 (0) ---
> 	kill(6433, SIGURG)                      = 0
> 
> IOW, the trace isn't saying anything at all, because all the real work 
> probably got done in that child process.

Ah yes, I knew the strace didn't tally with the reported behaviour,
but I'd been focusing on the SIGURG and missed the clone.  Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
