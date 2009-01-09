From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: mal_probe crash
Date: Sat, 10 Jan 2009 10:13:11 +1100
Message-ID: <1231542792.2142.87.camel@pasglop>
References: <20090107154434.0c9437ef@lappy.seanm.ca>
	 <20090108204634.GB2337@yoda.jdub.homelinux.org>
	 <1231368610.2142.27.camel@pasglop>
	 <Pine.LNX.4.64.0901091533000.13230@vixen.sonytel.be>
	 <20090109223410.GA18319@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>,
	"David S. Miller" <davem@davemloft.net>,
	Josh Boyer <jwboyer@gmail.com>,
	linuxppc-dev <linuxppc-dev@ozlabs.org>,
	Sean MacLennan <smaclennan@pikatech.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35776 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757708AbZAIXNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:13:37 -0500
In-Reply-To: <20090109223410.GA18319@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-01-10 at 09:34 +1100, Herbert Xu wrote:
> On Fri, Jan 09, 2009 at 03:42:25PM +0100, Geert Uytterhoeven wrote:
> > On Thu, 8 Jan 2009, Benjamin Herrenschmidt wrote:
> >
> > > There isn't that I know of. The EMAC code creates a single NAPI instance
> > > for all EMACs and I think used to completely disconnect things. The old
> > > code created a fake netdev just for NAPI, that became unnecessary with
> > > the new NAPI stuff.... but it looks like the way we do things now
> > > displeases some changes in the network stack. I'll have to dig.
> > 
> > Verified on my Sequoia (which now lost its network :-(
> > 
> > The regression/problem (requiring a valid net_device in netif_napi_add(), even
> > if CONFIG_NETPOLL=n) seems to be introduced by commit
> > d565b0a1a9b6ee7dff46e1f68b26b526ac11ae50 ("net: Add Generic Receive Offload
> > infrastructure").
> 
> Yes EMAC just needs to go back to the old fake dev setup.

One thing I wanted to do back then... which triggered the discussion
with Stephen just before he broke NAPI up from netdev, was to add a core
function that creates such dummy netdev so that drivers don't have to
break every time some new internal field changes or such...

I'll give that a spin asap, though it might have to wait for monday.

Cheers,
Ben.

