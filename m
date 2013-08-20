From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [RFC 0/2] Account for duplicate ACKs with invalid SACK-blocks
Date: Tue, 20 Aug 2013 09:36:21 +0200
Message-ID: <20130820073621.GB4185@cpaasch-mac>
References: <1376935800.4226.71.camel@edumazet-glaptop>
 <1376940568-16512-1-git-send-email-christoph.paasch@uclouvain.be>
 <52128CA6.6090001@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Phil Oester <kernel@linuxace.com>,
	Benjamin Hesmans <benjamin.hesmans@uclouvain.be>
To: Corey Hickey <bugfood-ml@fatooh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:55207 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab3HTHga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 03:36:30 -0400
Content-Disposition: inline
In-Reply-To: <52128CA6.6090001@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/08/13 - 14:22:46, Corey Hickey wrote:
> On 2013-08-19 12:29, Christoph Paasch wrote:
> > There exist sequence-number rewriting middleboxes, who do not modify the 
> > sequence-number in the SACK-blocks.
> > Duplicate acknowledgments with these (invalid) SACK-blocks will not be
> > accounted in sacked_out, and thus no fast-retransmit will trigger.
> > So, the only way to recover from a packet-loss is through an RTO,
> > effectively killing the performance of TCP in this case.
> > 
> > Performance-results can be seen here:
> > http://tools.ietf.org/agenda/87/slides/slides-87-tcpm-11.pdf
> > 
> > Another solution might be to simply disable SACK, as soon as an invalid
> > SACK-block has been received (as suggested by Phil Oester). This however
> > might be too aggressive.
> > 
> > Christoph Paasch (2):
> >   Use acked_out for reno-style ack acounting instead of sacked_out
> >   Account acked_out in sack, if the sack is invalid
> > 
> >  include/linux/tcp.h      |   1 +
> >  include/net/tcp.h        |  17 +++++---
> >  net/ipv4/tcp_input.c     | 103 ++++++++++++++++++++++++++++++++---------------
> >  net/ipv4/tcp_minisocks.c |   1 +
> >  net/ipv4/tcp_output.c    |   6 +--
> >  net/ipv4/tcp_timer.c     |   2 +-
> >  6 files changed, 89 insertions(+), 41 deletions(-)
> 
> I tested this patchset, and, unfortunately, the behavior seems to be the
> same.

Yes, because the problem is still on conntrack's side too.

As soon as conntrack will let pass the invalid SACK-blocks, you will
experience bad performance because every packet-loss can only be recovered
by an RTO.
My patchset tries to fix this last issue.


Cheers,
Christoph

> 
> I'm still planning on working with the Cisco device, when I can get some
> of the network admin's time, but that won't happen immediately.
> 
> Thanks,
> Corey
