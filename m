From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Bug in pskb_trim_rcsum()
Date: Tue, 18 Jul 2006 21:32:45 +1000
Message-ID: <20060718113245.GA12040@gondor.apana.org.au>
References: <E1G2S2h-0000nq-00@gondolin.me.apana.org.au> <006201c6aa06$d51581c0$6004a8c0@WeiYongjun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59401 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932175AbWGRLcs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 07:32:48 -0400
To: Wei Yongjun <yjwei@nanjing-fnst.com>
Content-Disposition: inline
In-Reply-To: <006201c6aa06$d51581c0$6004a8c0@WeiYongjun>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2006 at 09:09:34AM +0800, Wei Yongjun wrote:
>
> And in my test, UDP under IPv4 maybe do that.
> My UDP packet is:
> 
> packet1:
>  ___________________________________
> | Source Port               | Dest Port                   |
> |_________________|_________________|
> | Length = 16               | Checksum(*1)          |
> |_________________|_________________|
> |                          payload24                          |
> |__________________________________|

The whole point of CHECKSUM_UNNECESSARY is that the hardware parses
the protocol header for us.  So in this case it must calculate the
checksum for only the first 8 bytes of the payload.

If it does this incorrectly, then it doesn't support RX checksums at
all.

Which NIC is doing this BTW?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
