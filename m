From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Sat, 25 Apr 2009 00:30:09 +0800
Message-ID: <20090424163009.GA31585@gondor.apana.org.au>
References: <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com> <49E64BE4.1050908@myri.com> <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39001 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753731AbZDXQaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 12:30:17 -0400
Content-Disposition: inline
In-Reply-To: <49F1E5C8.7010303@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2009 at 12:16:08PM -0400, Andrew Gallatin wrote:
>
> Note that the GRO results were still obtained by (bogusly) setting
> CHECKSUM_UNNECESSARY.  I tried to use your patch, and I see
> terrible performance. Netperf shows between 1Gb/s to 2Gb/s (compared
> to 5Gb/s with GRO disabled).  I don't see bad checksums in netstat
> on the receiver, but it *feels* like something like that.

Well if the hardware checksum ends up being wrong then we'll always
fall back to using software checksums.  So somehow I doubt it's
causing what you're seeing.

> Here's a diff of netstat -st taken on the sender before and after
> a 5 second netperf:
> 2c2
> <     157 active connections openings
> ---
> >     159 active connections openings
> 7,9c7,9
> <     31465934 segments received
> <     72887021 segments send out
> <     679 segments retransmited
> ---
> >     32184827 segments received
> >     73473546 segments send out
> >     698 segments retransmited

So you're losing packets.  This is indeed something that I didn't
see here at all.  I'll see if I can get the card moved to an AMD
machine.

> This was using a net-next pulled 1/2 hour ago.  The only patch was your  
> GRO patch applied to myri10ge.  Do you have some other local patch
> which might be helping you?

I was using Linus's tree + the GRO patches from net-next.  I do
have two further optimisation patches applied but they don't
actually make much difference (I made them while trying to figure
out why cxgb3's GRO became slow again, which turned out to be sender
related).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
