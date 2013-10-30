From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 19:39:17 +0000
Message-ID: <1383161957.1601.27.camel@bwh-desktop.uk.level5networks.com>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131029.220253.1263087684709722001.davem@davemloft.net>
	 <20131030020543.GA1925@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<christoph.paasch@uclouvain.be>, <netdev@vger.kernel.org>,
	<hkchu@google.com>, <mwdalton@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:42201 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434Ab3J3TjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 15:39:21 -0400
In-Reply-To: <20131030020543.GA1925@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 10:05 +0800, Herbert Xu wrote:
> On Tue, Oct 29, 2013 at 10:02:53PM -0400, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Tue, 29 Oct 2013 17:53:48 -0700
> > 
> > > So should we apply the first fix to avoid the BUG_ON() ?
> > 
> > Please be more specific, are you talking about splitting up
> > this patch in some way?
> 
> I think Eric is referring to the patch that removes the BUG_ON
> in skb_segment and deals with the new mega-GRO packets.
> 
> I think that's fine for stable, but for the long term we should
> fix it properly as these new meag-GRO packets still retain the
> existing packet boundaries and are trivially segmentable.
> 
> If we are indeed able to do that, I doubt we would even need
> the sysctl patch since the GRO performance should be vastly
> superior to the non-GRO case, even for a router/bridge.

I think the change to enable mega-GRO packets should be reverted and
that change should go to stable so that the performance regression for
forwarding is also fixed.

Then it can be re-enabled, with the additional check that there are no
forwarders, in net-next.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
