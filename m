From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Thu, 13 Nov 2008 11:29:31 +0100
Message-ID: <1226572171.6834.87.camel@localhost.localdomain>
References: <20081112.014923.68124784.davem@davemloft.net>
	 <1226487710.6834.53.camel@localhost.localdomain>
	 <20081112.035240.226243372.davem@davemloft.net>
	 <20081112.041143.11487260.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:54383 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbYKMK3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 05:29:49 -0500
In-Reply-To: <20081112.041143.11487260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 04:11 -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 12 Nov 2008 03:52:40 -0800 (PST)
> 
> > Ok, Jesper, please try two things for me, leave the debugging patch
> > in there for all the tests:
> > 
> > 1) Retrigger the problem (with or without MSI, doesn't matter) but
> >    add back in that test I asked you to try last week.  The one
> >    where the "if (++rp->mark_counter == rp->mark_freq)" condition
> >    test in niu_start_xmit() is commented out, so that the
> >    "mrk |= TX_DESC_MARK;" statement always runs.
> > 
> >    Get me the log dump produced by that scenerio.
> > 
> > 2) Next, simply comment out the:
> > 
> >       if (unlikely(!(cs & (TX_CS_MK | TX_CS_MMK))))
> >               goto out;
> > 
> >    lines in niu_tx_work().
> > 
> > Let's see what new info we can get out of this.

Both applying test#1 and test#2.

After applying test#2, I cannot get it to do a TX transmit timed out.
And every thing seem to work... which after the known bug fix was kind
of the expected behaviour...

Although I'm not happy about the new perf numbers, as I now on a SMP
system only can route approx 290 kpps, remember I could route 319 kpps
using a single CPU nosmp kernel. (even more anyoing is that oprofile is
broken)

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
