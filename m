From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 20:39:53 +1000
Message-ID: <E1GI10b-0002d3-00@gondolin.me.apana.org.au>
References: <20060829.025400.37356422.davem@davemloft.net>
Cc: yoshfuji@linux-ipv6.org, okir@suse.de, netdev@vger.kernel.org,
	jbeulich@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:62221 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751021AbWH2KkV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 06:40:21 -0400
To: davem@davemloft.net (David Miller)
In-Reply-To: <20060829.025400.37356422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> But from another perspective (I assume these bridged Xen devices use
> ARPHRD_ETHER, do they?) a device with ARPHRD_ETHER and cleared
> IFF_MULTICAST flag seems potentially problematic.  How many other
> things break over such a device?

Netfilter is broken for a different reason.  It breaks because packets
pass through it twice, once going through brigde netfilter and once
through the Xen netloop interface.  So ideally they'd get rid of the
netloop device in which case they won't have to disable multicasting
on the bridge device anymore.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
