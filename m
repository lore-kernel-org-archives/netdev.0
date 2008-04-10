From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Thu, 10 Apr 2008 09:04:23 -0500
Message-ID: <20080410090423.6725adc5@speedy>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
 <873apwrc4t.fsf@basil.nowhere.org>
 <7i3apwbblk.fsf@lanthane.pps.jussieu.fr>
 <20080408163252.GS16647@one.firstfloor.org>
 <7iwsn8s107.fsf@lanthane.pps.jussieu.fr>
 <20080408175353.GA17147@one.firstfloor.org>
 <7ik5j7ghgh.fsf@lanthane.pps.jussieu.fr>
 <20080409174954.GD30885@one.firstfloor.org>
 <47FD6C0E.7040808@trash.net>
 <47FD6F85.5080003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:36777 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755971AbYDJOE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 10:04:28 -0400
In-Reply-To: <47FD6F85.5080003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Apr 2008 03:38:13 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Patrick McHardy wrote:
> > Andi Kleen wrote:
> >>> Random32 is initialised from get_random_bytes; so the per-cpu
> >>> pseudo-random sequences should be uncorrelated.  I fail to see how an
> >>> arbitrary interleaving of uncorrelated good pseudo-random sequences
> >>> can fail to be good.
> >>
> >> They are not necessarily uncorreleated, especially on platforms
> >> which do have poor entropy support and when your initialization happens
> >> at boot time. Take a look at how the random pool starts in random.c.
> >>
> >>> Looking at line 448 of sch_sfq.c in Linus' current HEAD, I see that
> >>> somebody else thinks the same as I do.  So please let me know if sfq
> >>> needs fixed, or whether I can use net_random in sfb.
> >>
> >> A lot of people get this wrong, but this doesn't mean that the
> >> problem should be readded in new code again.
> > 
> > 
> > Well, if I'm not mistaken net_random() used to be a function
> > (in net/core/utils.c) that didn't have this problem. So these
> > problems seem to have been introduced by the conversion to
> > srandom().
> 
> Two more noteworthy things:
> 
> - net_random() was intended to provide *mediocre* random,
> cheap to compute, not perfect. Good enough for many networking
> related things.
> 
> - traffic schedulers shouldn't depend on perfect random,
> its more about statistical multiplexing.

Anything related to random number seems to bring out the paranoia
in people.
