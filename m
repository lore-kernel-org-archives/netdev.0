From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 6430] New: ipsec tunnel : reply is not forwarded
Date: Thu, 13 Jul 2006 22:10:11 +1000
Message-ID: <E1G101D-0007p3-00@gondolin.me.apana.org.au>
References: <20060628080256.GA13787@illicom.com>
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46348 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751489AbWGMMKY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 08:10:24 -0400
To: raphael.astier@illicom.com (Raphael Astier)
In-Reply-To: <20060628080256.GA13787@illicom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Raphael Astier <raphael.astier@illicom.com> wrote:
>  
> On GW1 :
> #setkey -f 
> flush;
> spdflush;
> add 192.168.1.1 192.168.1.2 esp 1000 -m tunnel -E des-cbc "12345678";
> spdadd 10.0.0.0/24 11.0.0.0/24 any -P out ipsec
> esp/tunnel/192.168.1.1-192.168.1.2/require;
> 
> On GW2 : (only need to have SPI to decrypt packets coming from GW1) 
> #!/usr/local/sbin/setkey -f
> flush;
> spdflush;
> add -n 192.168.1.1 192.168.1.2 esp 1000 -m tunnel -E des-cbc "12345678";

This can't possibly work since inbound policies are required for
tunnel-mode SAs (otherwise people can send packets with arbitrary
source addresses once they have a tunnel-mode SA with you).

So you need at least 1 more policy on GW1 and 2 policies on GW2
for this to have a chance of working.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
