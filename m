From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Thu, 21 Jul 2011 15:46:21 -0700
Message-ID: <4E28AC3D.1010907@hp.com>
References: <1311150327.2338.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<1311157648.2338.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<4E2781A2.8020905@gont.com.ar> <20110721.151750.995903739612693126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fernando@gont.com.ar, eric.dumazet@gmail.com, security@kernel.org,
	eugeneteo@kernel.sg, netdev@vger.kernel.org, mpm@selenic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:40904 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab1GUWqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 18:46:24 -0400
In-Reply-To: <20110721.151750.995903739612693126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2011 03:17 PM, David Miller wrote:
> From: Fernando Gont<fernando@gont.com.ar>
> Date: Wed, 20 Jul 2011 22:32:18 -0300
>
>> Does it make sense to go in this direction rather than simply randomize
>> the IPv6 Fragment Identification?
>
> We could, but that's actually a bit more work.
>
> You have to avoid recycling IDs to the same destination host otherwise
> a retransmit could use the same ID and overlap with a previous set of
> frags, causing corruption.

I think you mean ID reuse rather than packet retransmit no?

It is the same "frankengram" issue present in IPv4 with its now puny 16 
bit id field. Doesn't that pretty much rely on layer4 or higher 
checksums to avoid corruption?

> This means if you go the "pure random" route, you have to make sure
> that the 32-bit series produced by the random number generator is
> maximally long.  This is why openbsd uses an ID generator based upon
> skip32 etc.
>
> And I cannot say that about our RNG infrastructure.
>
> Also, 32-bits seems like a lot, but on a 40Gb link we can exhaust this
> space in ~20 minutes (1554 byte packet over standard ethernet MTU at
> 40Gbit is ~3454767 ipv6 frag IDs per second).  So while maybe not a
> serious issue right now, we seem to go up by a factor of 10 every few
> years, therefore at ~400Gb it's down to 2 minutes.

With mode-rr and bonding (and enough CPU) you could probably get it down 
to 2 minutes without having to wait a few years.

rick jones

> So we have to look at it like a constrained resource, and therefore
> doing it on a per-destination basis like ipv4 makes a lot of sense.
>
> I think Eric's work is the way forward and I'll be applying his patches.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

