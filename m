From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Bug in pskb_trim_rcsum()
Date: Tue, 18 Jul 2006 23:04:04 +1000
Message-ID: <20060718130404.GA12785@gondor.apana.org.au>
References: <E1G2S2h-0000nq-00@gondolin.me.apana.org.au> <006201c6aa06$d51581c0$6004a8c0@WeiYongjun> <20060718113245.GA12040@gondor.apana.org.au> <20060718125439.GA19770@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <yjwei@nanjing-fnst.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41995 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932187AbWGRNER
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 09:04:17 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060718125439.GA19770@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2006 at 04:54:39PM +0400, Alexey Kuznetsov wrote:
>
> I preferred optimistic approach: if the checksum comes out correct,
> we do not really care, how device calculated it. Probably, it calculated
> checksum over wrong data, but got a good checksum. So what? It is
> not a crypto digest yet. And if device found wrong checksum, we will
> recalculate it anyway.

Agreed.

> I would like to add that CHECKSUM_UNNECESSARY can be used, when
> checksum is really wrong (on loopback), that's why it is not cleared,
> when trimming. CHECKSUM_HW can always fall back to CHECKSUM_NONE,
> but CHECKSUM_UNNECESSARY cannot. Probably, this was bad idea, but
> it still means that if some generic function starts to clear it,
> all the code using it should be reverified.

Actually, I plan to differentiate between RX CHECKSUM_HW and TX
CHECKSUM_HW.  Now that we have things like Xen it is possible for
RX packets to have patial checksums too.

When this is done loopback can send TX CHECKSUM_HW packets instead
of CHECKSUM_UNNECESSARY (I'm currently calling this CHECKSUM_PARTIAL).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
