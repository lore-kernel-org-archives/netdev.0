From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Sun, 03 Nov 2013 20:23:02 -0800
Message-ID: <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131029090849.GC5944@cpaasch-mac>
	 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
	 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:58151 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab3KDEXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 23:23:04 -0500
Received: by mail-pb0-f42.google.com with SMTP id jt11so6685827pbb.29
        for <netdev@vger.kernel.org>; Sun, 03 Nov 2013 20:23:03 -0800 (PST)
In-Reply-To: <20131104041108.GA22823@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-04 at 12:11 +0800, Herbert Xu wrote:
> On Sun, Nov 03, 2013 at 09:26:43AM -0800, Eric Dumazet wrote:
> > 
> > Not really.
> > 
> > Have you took a look at the GSO path recently ?
> > 
> > The days it was handling only IP+TCP are gone.
> > 
> > If you think you can do better, please do so.
> 
> OK maybe I overreacted.
> 
> With regards to your point 2), GRO does not introduce any latencies
> because it simply relies on NAPI to do the aggregation.  IOW it is
> no better or worse latency-wise compared to NAPI.  If you need to
> tune it, just use the usual NAPI toggles.
> 

Well, GRO adds latencies for sure.

You seem to assume the transmit only can happen when NAPI is done, but
its not true. As soon as GRO fills one packet (reaches max capacity),
packet is delivered and forwarded, even if NAPI handler is not yet
complete for the flow.

Say you have 1 us per MSS, then filling 45 MSS per skb means we add a 45
us delay transit, instead of 16 us, or 1 us if no GRO is used on the
router.



> With repsect to point 3), sure we can allow the generation of TSO
> segments in skb_segment.
> 
> You may be right that this is all too hard, since I haven't actually
> sat down and tried to do it yet.
> 
> But please give me chance to have a look first before we give up and
> install a permanent user-space toggle.

I don't think I ever said it was permanent, I am sorry you understood
this.

I will be happy to change skb_segment() in the future, but I already
said I would not expect doing so for linux-3.13, given we were too late
in the linux-3.12-rc.

Thanks
