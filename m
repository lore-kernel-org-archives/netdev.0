From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP send/ack lockstep problem
Date: Sat, 02 Sep 2006 16:14:24 +1000
Message-ID: <E1GJOls-0008Jv-00@gondolin.me.apana.org.au>
References: <20060902055317.GA5567@kiste.smurf.noris.de>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57100 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750802AbWIBGOX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 02:14:23 -0400
To: smurf@smurf.noris.de (Matthias Urlichs)
In-Reply-To: <20060902055317.GA5567@kiste.smurf.noris.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthias Urlichs <smurf@smurf.noris.de> wrote:
>
> The stuff I see in there doesn't look stupid to me.
> 
> accept(...) = 216
> setsockopt(216, SOL_IP, IP_TOS, [8], 4) = 0
> setsockopt(216, SOL_TCP, TCP_NODELAY, [1], 4) = 0
> setsockopt(216, SOL_SOCKET, SO_KEEPALIVE, [1], 4) = 0
> followed by a bunch of "interactive" read() and write() calls, and then
> a rather long sequence of 16384-byte writes (all of which end up being
> partial because the send buffer size is 12k).

Please send the actual strace with the options -ttT.  If you can also
send the tcpdumps that occur at the same time then we can match them up
and figure out what's going on.

So far the only thing I can see from your original tcpdump is that every
other ack is followed by a noticeable delay before a packet is sent.
This is a typical symptom when the appliation has nothing in the buffer.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
VGER BF report: U 0.499395
