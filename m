From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Thu, 10 Apr 2008 03:38:13 +0200
Message-ID: <47FD6F85.5080003@trash.net>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr> <873apwrc4t.fsf@basil.nowhere.org> <7i3apwbblk.fsf@lanthane.pps.jussieu.fr> <20080408163252.GS16647@one.firstfloor.org> <7iwsn8s107.fsf@lanthane.pps.jussieu.fr> <20080408175353.GA17147@one.firstfloor.org> <7ik5j7ghgh.fsf@lanthane.pps.jussieu.fr> <20080409174954.GD30885@one.firstfloor.org> <47FD6C0E.7040808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65253 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbYDJBiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 21:38:17 -0400
In-Reply-To: <47FD6C0E.7040808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Andi Kleen wrote:
>>> Random32 is initialised from get_random_bytes; so the per-cpu
>>> pseudo-random sequences should be uncorrelated.  I fail to see how an
>>> arbitrary interleaving of uncorrelated good pseudo-random sequences
>>> can fail to be good.
>>
>> They are not necessarily uncorreleated, especially on platforms
>> which do have poor entropy support and when your initialization happens
>> at boot time. Take a look at how the random pool starts in random.c.
>>
>>> Looking at line 448 of sch_sfq.c in Linus' current HEAD, I see that
>>> somebody else thinks the same as I do.  So please let me know if sfq
>>> needs fixed, or whether I can use net_random in sfb.
>>
>> A lot of people get this wrong, but this doesn't mean that the
>> problem should be readded in new code again.
> 
> 
> Well, if I'm not mistaken net_random() used to be a function
> (in net/core/utils.c) that didn't have this problem. So these
> problems seem to have been introduced by the conversion to
> srandom().

Two more noteworthy things:

- net_random() was intended to provide *mediocre* random,
cheap to compute, not perfect. Good enough for many networking
related things.

- traffic schedulers shouldn't depend on perfect random,
its more about statistical multiplexing.



