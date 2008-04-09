From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Wed, 9 Apr 2008 19:49:54 +0200
Message-ID: <20080409174954.GD30885@one.firstfloor.org>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr> <873apwrc4t.fsf@basil.nowhere.org> <7i3apwbblk.fsf@lanthane.pps.jussieu.fr> <20080408163252.GS16647@one.firstfloor.org> <7iwsn8s107.fsf@lanthane.pps.jussieu.fr> <20080408175353.GA17147@one.firstfloor.org> <7ik5j7ghgh.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51785 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbYDIRpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 13:45:24 -0400
Content-Disposition: inline
In-Reply-To: <7ik5j7ghgh.fsf@lanthane.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Random32 is initialised from get_random_bytes; so the per-cpu
> pseudo-random sequences should be uncorrelated.  I fail to see how an
> arbitrary interleaving of uncorrelated good pseudo-random sequences
> can fail to be good.

They are not necessarily uncorreleated, especially on platforms
which do have poor entropy support and when your initialization happens
at boot time. Take a look at how the random pool starts in random.c.

> 
> Looking at line 448 of sch_sfq.c in Linus' current HEAD, I see that
> somebody else thinks the same as I do.  So please let me know if sfq
> needs fixed, or whether I can use net_random in sfb.

A lot of people get this wrong, but this doesn't mean that the
problem should be readded in new code again.

-Andi
