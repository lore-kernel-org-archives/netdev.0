From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Fri, 11 Apr 2008 15:07:19 +0200
Message-ID: <47FF6287.7010601@trash.net>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>	<873apwrc4t.fsf@basil.nowhere.org>	<7i3apwbblk.fsf@lanthane.pps.jussieu.fr>	<20080408163252.GS16647@one.firstfloor.org>	<7iwsn8s107.fsf@lanthane.pps.jussieu.fr>	<20080408175353.GA17147@one.firstfloor.org>	<7ik5j7ghgh.fsf@lanthane.pps.jussieu.fr>	<20080409174954.GD30885@one.firstfloor.org>	<47FD6C0E.7040808@trash.net> <47FD6F85.5080003@trash.net> <7izls2uffi.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54001 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbYDKNHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:07:22 -0400
In-Reply-To: <7izls2uffi.fsf@lanthane.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Juliusz Chroboczek wrote:
>> - traffic schedulers shouldn't depend on perfect random,
>> its more about statistical multiplexing.
> 
> Okay, I've been thinking about this, and I'm not quite sure that what
> sfq and sfb want is a pseudo-random sequence in the first place.
> 
> Sfq and sfb only draw random numbers in order to change hashing
> functions periodically, so as not to have an innocent flow stuck
> within a hash bucket with a non-reactive flow.  For sfb it doesn't
> matter much (collisions in a Bloom filter are so rare as to be almost
> nonexistent), but for sfq, it is fairly important.
> 
> Now assuming jhash is any good, i.e. that a single bit change in the
> input changes all output bits with roughly similar probability (and
> I don't know whether it is), it shouldn't matter much what sequence of
> u32 we use for the perturbation as long as it doesn't repeat values
> too often.  Something as simple as a static counter might actually be
> good enough.
> 
> So I'd argue that the wise thing is to make sure of is that jhash is
> good (in the sense above), and not bother too much with the PRNG.


Agreed. jhash gives pretty good distribution, so we should be fine.
