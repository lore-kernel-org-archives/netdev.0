From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Subject: Re: [PATCH] Stochastic Fair Blue queue discipline
Date: Tue, 08 Apr 2008 17:38:47 +0200
Message-ID: <7i3apwbblk.fsf@lanthane.pps.jussieu.fr>
References: <87skxxb8br.fsf@pirx.pps.jussieu.fr>
	<873apwrc4t.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva.jussieu.fr ([134.157.0.129]:63555 "EHLO shiva.jussieu.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752294AbYDHPko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 11:40:44 -0400
In-Reply-To: <873apwrc4t.fsf@basil.nowhere.org> (Andi Kleen's message of "Tue\, 08 Apr 2008 10\:20\:34 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> (read Documentation/CodingStyle)

Will do, thanks for the pointer.

>> +static unsigned sfb_hash(struct sk_buff *skb, int hash, int filter,
>> +                         struct sfb_sched_data *q)

> I think we have multiple qdiscs now doing very similar such hashes.
> Any chance this could be factored out into a common library function 
> first?

I'll be glad to do so.  Where shall I put it?

> Getting high res time can be actually somewhat expensive on different
> platforms. I would recommend to only use it if it's actually needed in
> the inelastic flow case below and use jiffies to check for rehashing.

Good point.

> /dev/random is a precious resource (some systems have very little
> true entropy) and getting that much data from it regularly is not
> a good idea because you take it away from other users who really
> need it

In the default configuration, I'm getting 32 bytes every 10 minutes,
which seemed reasonable.  This code was copied from sch_sfq (function
sfq_perturbation), which does the very same thing.

> But in any case it is likely better you only get the
> get_random_bytes() entropy once and then use that to init some kind
> of RNG (either a secure one if it's for security or some random fast
> one if it's not) and then use that output for rehashing.

Could do, but in that case the RNG should be shared between sfq and
sfb.  Shall I simply use net_random (which calls random32) ?

                                        Juliusz
