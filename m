From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: [PATCH net-next-2.6] ipv6: make fragment identifications less
 predictable
Date: Thu, 21 Jul 2011 20:37:48 -0300
Message-ID: <4E28B84C.2090305@gont.com.ar>
References: <1311150327.2338.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<1311157648.2338.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	<4E2781A2.8020905@gont.com.ar> <20110721.151750.995903739612693126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, security@kernel.org, eugeneteo@kernel.sg,
	netdev@vger.kernel.org, mpm@selenic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:54451 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722Ab1GUXj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 19:39:59 -0400
Received: by yia27 with SMTP id 27so915374yia.19
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2011 16:39:58 -0700 (PDT)
In-Reply-To: <20110721.151750.995903739612693126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/2011 07:17 PM, David Miller wrote:
>> Does it make sense to go in this direction rather than simply randomize
>> the IPv6 Fragment Identification?
> 
> We could, but that's actually a bit more work.
> 
> You have to avoid recycling IDs to the same destination host otherwise
> a retransmit could use the same ID and overlap with a previous set of
> frags, causing corruption.
> 
> This means if you go the "pure random" route, you have to make sure
> that the 32-bit series produced by the random number generator is
> maximally long.  This is why openbsd uses an ID generator based upon
> skip32 etc.

That scenario assumes packet reordering and/or packet loss. In that
case, and at those packet rates, I'd argue that you shoudn't be relying
on fragmentation, anyway (e.g., use PMTUD).


> So we have to look at it like a constrained resource, and therefore
> doing it on a per-destination basis like ipv4 makes a lot of sense.
> 
> I think Eric's work is the way forward and I'll be applying his patches.

While I haven't had a chance to look at the patch yet, I was wondering
whether it defines both a separe "offset" and "counter" for each "flow".

(assuming that Identification values are selected as a result of ID =
offset + counter, where counter is incremented for each packet that is
sent, and offset is some value that depends on (src IP, dst ip)).

If you have separate "offset" for each flow, you solve the problem of
"predictable Identification values". However, if there's a single global
"counter", you're still subject of being exploited for an "idle scan").

Thanks,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@acm.org
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1



