From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: WARNING (skb_gso_segment) with tg3+bridge in 2.6.27
Date: Thu, 23 Oct 2008 10:20:01 +0800
Message-ID: <20081023022001.GB304@gondor.apana.org.au>
References: <20081011172002.GA12659@pest> <20081013.004226.171259546.davem@davemloft.net> <20081022074502.GA25058@gondor.apana.org.au> <20081022175704.GA25286@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"berni@birkenwald.de" <berni@birkenwald.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51971 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758801AbYJWCUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 22:20:10 -0400
Content-Disposition: inline
In-Reply-To: <20081022175704.GA25286@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2008 at 10:57:04AM -0700, Matt Carlson wrote:
>
> Looking at the dmesg output, I see that the tg3 device is a 5714.
> NETIF_F_TSO6 should not be enabled for the 5714.  Why is the driver
> getting an IPv6 TSO packet?

This might be caused by the bridge enabling TSO6 due to GSO
being enabled on the underlying device which is a result of
it supporting SG.

> > So my question is to the tg3 developers, does having TSO6 without
> > IPv6 checksums ever make sense?
> 
> No.  TSO implies checksum offload.

OK that's good to know.

> > Put it another way, how can you
> > have a device that can compute checksums for TCPv6 packets but
> > not UDPv6 packets?
> 
> The checksum operations should be exactly the same between the two.
> I can't help but wonder why UDP entered the scene though.  The tg3
> driver never sets NETIF_F_UFO.

What I meant is the NETIF_F_TSO6 bit vs. NETIF_F_IPV6_CSUM bit.
My question is essentially does having the first bit always mean
that the second bit is set.  The second bit stands for support
of TCPv6 and UDPv6 checksum offload (which is not necessarily
related to TSO or UFO).

The thing which I wasn't sure about is that the conditions which
determine which one of these bits are set do not look the same
in tg3.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
