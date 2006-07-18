From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] Bug in pskb_trim_rcsum()
Date: Tue, 18 Jul 2006 16:54:39 +0400
Message-ID: <20060718125439.GA19770@ms2.inr.ac.ru>
References: <E1G2S2h-0000nq-00@gondolin.me.apana.org.au> <006201c6aa06$d51581c0$6004a8c0@WeiYongjun> <20060718113245.GA12040@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <yjwei@nanjing-fnst.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:10171 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932179AbWGRMzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 08:55:46 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060718113245.GA12040@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> The whole point of CHECKSUM_UNNECESSARY is that the hardware parses
> the protocol header for us.  So in this case it must calculate the
> checksum for only the first 8 bytes of the payload.

I remember this place, I stalled there for a minute ages ago.

He is right in his doubts, the place is confusing, device do it wrong
(but they are innocent, it is just a flaw of UDP, people did not know
what to do with redundant two octets in header and placed some useless
thing there :-)) and if we want to be paranoid about checksum,
we should really clear CHECKSUM_UNNECESSARY tag and to recheck.

I preferred optimistic approach: if the checksum comes out correct,
we do not really care, how device calculated it. Probably, it calculated
checksum over wrong data, but got a good checksum. So what? It is
not a crypto digest yet. And if device found wrong checksum, we will
recalculate it anyway.


I would like to add that CHECKSUM_UNNECESSARY can be used, when
checksum is really wrong (on loopback), that's why it is not cleared,
when trimming. CHECKSUM_HW can always fall back to CHECKSUM_NONE,
but CHECKSUM_UNNECESSARY cannot. Probably, this was bad idea, but
it still means that if some generic function starts to clear it,
all the code using it should be reverified.

Alexey
