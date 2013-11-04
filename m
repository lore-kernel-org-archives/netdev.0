From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sun, 03 Nov 2013 21:00:54 -0800
Message-ID: <1383541254.4291.82.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <20131104042913.GA23021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:62500 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab3KDFAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 00:00:55 -0500
Received: by mail-pb0-f51.google.com with SMTP id xa7so805213pbc.24
        for <netdev@vger.kernel.org>; Sun, 03 Nov 2013 21:00:55 -0800 (PST)
In-Reply-To: <20131104042913.GA23021@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-04 at 12:29 +0800, Herbert Xu wrote:
> On Sun, Nov 03, 2013 at 08:23:02PM -0800, Eric Dumazet wrote:
> > 
> > Well, GRO adds latencies for sure.
> > 
> > You seem to assume the transmit only can happen when NAPI is done, but
> > its not true. As soon as GRO fills one packet (reaches max capacity),
> > packet is delivered and forwarded, even if NAPI handler is not yet
> > complete for the flow.
> 
> Have you actually measured this? The latency added by GRO is pure
> processing overhead.  This is tiny when compared to the time NAPI takes
> to wait.


Please take a look at 

2e71a6f8084e net: gro: selective flush of packets
