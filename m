From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: mal_probe crash
Date: Sat, 10 Jan 2009 09:34:10 +1100
Message-ID: <20090109223410.GA18319@gondor.apana.org.au>
References: <20090107154434.0c9437ef@lappy.seanm.ca> <20090108204634.GB2337@yoda.jdub.homelinux.org> <1231368610.2142.27.camel@pasglop> <Pine.LNX.4.64.0901091533000.13230@vixen.sonytel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	"David S. Miller" <davem@davemloft.net>,
	Josh Boyer <jwboyer@gmail.com>,
	linuxppc-dev <linuxppc-dev@ozlabs.org>,
	Sean MacLennan <smaclennan@pikatech.com>,
	netdev@vger.kernel.org
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55485 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759889AbZAIWed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 17:34:33 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901091533000.13230@vixen.sonytel.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 03:42:25PM +0100, Geert Uytterhoeven wrote:
> On Thu, 8 Jan 2009, Benjamin Herrenschmidt wrote:
>
> > There isn't that I know of. The EMAC code creates a single NAPI instance
> > for all EMACs and I think used to completely disconnect things. The old
> > code created a fake netdev just for NAPI, that became unnecessary with
> > the new NAPI stuff.... but it looks like the way we do things now
> > displeases some changes in the network stack. I'll have to dig.
> 
> Verified on my Sequoia (which now lost its network :-(
> 
> The regression/problem (requiring a valid net_device in netif_napi_add(), even
> if CONFIG_NETPOLL=n) seems to be introduced by commit
> d565b0a1a9b6ee7dff46e1f68b26b526ac11ae50 ("net: Add Generic Receive Offload
> infrastructure").

Yes EMAC just needs to go back to the old fake dev setup.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
