From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Thu, 5 May 2011 08:34:15 +1000
Message-ID: <20110504223415.GA14819@gondor.apana.org.au>
References: <20110504181813.GA17547@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44798 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011Ab1EDWeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 18:34:23 -0400
Content-Disposition: inline
In-Reply-To: <20110504181813.GA17547@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 04, 2011 at 09:18:14PM +0300, Michael S. Tsirkin wrote:
> BTW, I just noticed that net-next spits out
> many of the following when I run any VMs:
> 
> tap0: Dropping NETIF_F_SG since no checksum feature.
> tap0: Dropping NETIF_F_GSO since no SG feature.
> tap0: Features changed: 0x401b4849 -> 0x40004040
> device msttap0 entered promiscuous mode
> br0: Dropping NETIF_F_GSO since no SG feature.
> br0: port 1(msttap0) entering forwarding state
> br0: port 1(msttap0) entering forwarding state
> tap0: Features changed: 0x40004040 -> 0x40024849
> tap0: Dropping NETIF_F_SG since no checksum feature.
> tap0: Dropping NETIF_F_GSO since no SG feature.
> tap0: Features changed: 0x40024849 -> 0x40004040
> br0: Dropping NETIF_F_GSO since no SG feature.
> tap0: Dropping NETIF_F_SG since no checksum feature.
> tap0: Dropping NETIF_F_GSO since no SG feature.
> tap0: Dropping NETIF_F_SG since no checksum feature.
> tap0: Dropping NETIF_F_GSO since no SG feature.
> tap0: Dropping NETIF_F_SG since no checksum feature.
> tap0: Dropping NETIF_F_GSO since no SG feature.
> tap0: Dropping NETIF_F_SG since no checksum feature.
> tap0: Dropping NETIF_F_GSO since no SG feature.
> tap0: Features changed: 0x40004040 -> 0x401b4849
> tap0: Dropping NETIF_F_SG since no checksum feature.
> tap0: Dropping NETIF_F_GSO since no SG feature.
> tap0: Features changed: 0x401b4849 -> 0x40004040
> br0: Dropping NETIF_F_GSO since no SG feature.
> 
> My problem is not primarily with warnings:
> 
> will that linearize all packets and disable GSO
> for tap and bridge? If yes it can't be good
> for performance...

I think so.  So the question is why is checksum off?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
