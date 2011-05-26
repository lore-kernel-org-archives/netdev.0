From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [BUG] netconsole broken by scheduler updates
Date: Thu, 26 May 2011 18:17:55 +0200
Message-ID: <1306426675.2497.84.camel@laptop>
References: <4DDE1B7D.7080707@free.fr> <1306403308.1200.44.camel@twins>
	 <alpine.DEB.2.02.1105261217240.5114@localhost6.localdomain6>
	 <4DDE7BEB.1050507@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Laurent Riffard <laurent.riffard@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50380 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754017Ab1EZQOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 12:14:33 -0400
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QPdCx-00005o-1u
	for netdev@vger.kernel.org; Thu, 26 May 2011 16:14:47 +0000
In-Reply-To: <4DDE7BEB.1050507@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-26 at 18:12 +0200, Laurent Riffard wrote:
> Le 26/05/2011 12:35, Laurent Riffard a =C3=A9crit :
> > On Thu, 26 May 2011, Peter Zijlstra wrote:
> >> On Thu, 2011-05-26 at 11:21 +0200, Laurent Riffard wrote:
> >>> Hi,
> >>>
> >>> Recently, netconsole was broken by some scheduler updates. Kernel=
 hangs
> >>> on boot near the network card initialization. I noticed that it d=
oes
> >>> hang just where a "inconsistent lock state" message normally appe=
ars.
> >>>
> >>> I did a bisection : e4a52bcb9a18142d79e231b6733cabdbf2e67c1f is t=
he
> >>> first bad commit.
> >>> commit e4a52bcb9a18142d79e231b6733cabdbf2e67c1f
> >>> Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
> >>> Date:   Tue Apr 5 17:23:54 2011 +0200
> >>>
> >>>     sched: Remove rq->lock from the first half of ttwu()
> >>>
> >>>
> >>> Before this commit, kernel was booting succesfully despite the
> >>> "inconsistent lock state" message. After this commit, the kernel =
does
> >>> hang on boot, I have to push the reset button.
> >>
> >> Do you have CONFIG_HARDLOCKUP_DETECTOR=3Dy, and do you get an NMI =
splat
> >> after some 10 seconds? It would be interesting to see where its st=
uck.
> >=20
> > CONFIG_HARDLOCKUP_DETECTOR is not set for now. I'll give it a try.
>=20
> I activated CONFIG_HARDLOCKUP_DETECTOR, but failed to obtain more=20
> information. During the boot, the kernel hangs just after bringing up=
=20
> the NIC. I waited 2 minutes, without getting any more messages.

OK, thanks for trying, I shall try and reproduce locally.


