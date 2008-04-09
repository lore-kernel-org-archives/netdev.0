From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Wed, 09 Apr 2008 17:45:34 +0200
Message-ID: <7ik5j7ghgh.fsf@lanthane.pps.jussieu.fr>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
	<873apwrc4t.fsf@basil.nowhere.org>
	<7i3apwbblk.fsf@lanthane.pps.jussieu.fr>
	<20080408163252.GS16647@one.firstfloor.org>
	<7iwsn8s107.fsf@lanthane.pps.jussieu.fr>
	<20080408175353.GA17147@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:63398 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425AbYDIPpk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 11:45:40 -0400
In-Reply-To: <20080408175353.GA17147@one.firstfloor.org> (Andi Kleen's message of "Tue\, 8 Apr 2008 19\:53\:53 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > no net_random/srandom32 is per CPU and likely does the wrong thing for you.

>> Why is that?  I'm only using this to initialise a global data
>> structure, why should it matter that I use per-cpu state?

> Because they're independent and there is no guarantee you always 
> run on the same CPU and sampling them randomly will not necessarily
> give you a good random number sequence.

I'm sorry to be such a pain, but I still don't understand.

Random32 is initialised from get_random_bytes; so the per-cpu
pseudo-random sequences should be uncorrelated.  I fail to see how an
arbitrary interleaving of uncorrelated good pseudo-random sequences
can fail to be good.

Looking at line 448 of sch_sfq.c in Linus' current HEAD, I see that
somebody else thinks the same as I do.  So please let me know if sfq
needs fixed, or whether I can use net_random in sfb.

Thanks,

                                        Juliusz
