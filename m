From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: account SYN-ACK timeouts & retransmissions
Date: Wed, 13 Jan 2010 23:07:59 +0200
Message-ID: <201001132307.59472.opurdila@ixiacom.com>
References: <1262808658-29346-1-git-send-email-opurdila@ixiacom.com> <20100111.161537.85213244.davem@davemloft.net> <201001121855.32018.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpyatkovskiy@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:5316 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756211Ab0AMVL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 16:11:27 -0500
In-Reply-To: <201001121855.32018.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 January 2010 18:55:31 you wrote:
> On Tuesday 12 January 2010 02:15:37 you wrote:
> > From: Octavian Purdila <opurdila@ixiacom.com>
> > Date: Tue, 12 Jan 2010 00:16:33 +0200
> >
> > > On Friday 08 January 2010 03:25:07 you wrote:
> > >> From: Octavian Purdila <opurdila@ixiacom.com>
> > >> Date: Wed,  6 Jan 2010 22:10:58 +0200
> > >>
> > >> > Signed-off-by: Maksim Pyatkovskiy <mpyatkovskiy@ixiacom.com>
> > >> > Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> > >>
> > >> RETRANSSEGS is meant to count data segments retransmits, not pure
> > >> control frames.
> > >>
> > >> Similarly for TCPTIMEOUTS, it's mean for data retransmit timeouts.
> > >>
> > >> If you overload these statistics with other similar events, they
> > >> become less meaningful.
> > >
> > > But we do increment RETRANSSEGS & TCPTIMEOUTS for SYNs. This creates an
> > > imbalance in client/server stats which makes things harder to diagnose.
> >
> > Interesting.
> >
> > Can you do me a favor and look into the code history and see
> > if we used to account both sides?
> 
> Sure.

I think we lost the SynAck accounting with this commit from the netdev-vger-
cvs tree, where tcp_syn_recv_timer was introduced:

commit 2248761e5cfcb8687563b29c77064185e7604947
Author: davem <davem>
Date:   Sun Nov 10 21:25:00 1996 +0000

    Merge to 2.1.8, IPV6 is here.  Also fix
    a stupid bug in the kernel unaligned trap handler
    where st %g0, [foo] would fail miserably.


Before this, both Syns and SynAcks seems to be accounted for.
