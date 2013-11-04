From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sun, 03 Nov 2013 22:05:55 -0800
Message-ID: <1383545155.4291.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104042913.GA23021@gondor.apana.org.au>
	 <1383541254.4291.82.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104052321.GA23252@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:43211 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab3KDGF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 01:05:58 -0500
Received: by mail-pd0-f177.google.com with SMTP id p10so6256444pdj.36
        for <netdev@vger.kernel.org>; Sun, 03 Nov 2013 22:05:57 -0800 (PST)
In-Reply-To: <20131104052321.GA23252@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-04 at 13:23 +0800, Herbert Xu wrote:
> On Sun, Nov 03, 2013 at 09:00:54PM -0800, Eric Dumazet wrote:
> > On Mon, 2013-11-04 at 12:29 +0800, Herbert Xu wrote:
> >
> > > Have you actually measured this? The latency added by GRO is pure
> > > processing overhead.  This is tiny when compared to the time NAPI takes
> > > to wait.
> > 
> > Please take a look at 
> > 
> > 2e71a6f8084e net: gro: selective flush of packets
> 
> This is a different problem altogether.  I was worried about the
> latency in cases where we're idle and waiting for new data, while
> you're worried about the latency in the CPU-bound case.

Idle case, you very rarely cant keep up building skbs with 16 MSS.

> 
> I think we can definitely improve our behaviour the CPU-bound case.
> Right now if we encounter something we can't hold for GRO we
> start processing it right away.  Instead we can place it in a
> list for later processing together with the GRO packets.
> 
> This way GRO packets are not penalised by non-GRO packets.
> 
> You can then use the usual NAPI budget to minimise latency and
> ensure scheduling fairness.

We had these latencies only dealing with TCP packets, all GRO
candidates.

Really, I think we have used GRO at large scale here at Google ;)
