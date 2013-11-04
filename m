From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Mon, 4 Nov 2013 12:29:13 +0800
Message-ID: <20131104042913.GA23021@gondor.apana.org.au>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103122824.GA17394@gondor.apana.org.au>
 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131103163103.GA18894@gondor.apana.org.au>
 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38229 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751527Ab3KDE3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 23:29:21 -0500
Content-Disposition: inline
In-Reply-To: <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 03, 2013 at 08:23:02PM -0800, Eric Dumazet wrote:
> 
> Well, GRO adds latencies for sure.
> 
> You seem to assume the transmit only can happen when NAPI is done, but
> its not true. As soon as GRO fills one packet (reaches max capacity),
> packet is delivered and forwarded, even if NAPI handler is not yet
> complete for the flow.

Have you actually measured this? The latency added by GRO is pure
processing overhead.  This is tiny when compared to the time NAPI takes
to wait.

> Say you have 1 us per MSS, then filling 45 MSS per skb means we add a 45
> us delay transit, instead of 16 us, or 1 us if no GRO is used on the
> router.

Are you talking about the latency added by the TX qdisc? That is
not GRO's fault.  Perhaps we can add more metadata to the GRO packet
so that the TX qdisc can deal with it appropriately?

> > But please give me chance to have a look first before we give up and
> > install a permanent user-space toggle.
> 
> I don't think I ever said it was permanent, I am sorry you understood
> this.
> 
> I will be happy to change skb_segment() in the future, but I already
> said I would not expect doing so for linux-3.13, given we were too late
> in the linux-3.12-rc.

For the time being my preference is for your linearisation patch, followed
by a revert of the GRO patch, and lastly the magic toggle that turns this
off for forwarding systems.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
