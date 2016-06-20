From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: esp: Fix ESN generation under UDP encapsulation
Date: Mon, 20 Jun 2016 12:59:34 +0200
Message-ID: <20160620105934.GL7698@gauss.secunet.com>
References: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
 <20160613102024.GX7698@gauss.secunet.com>
 <5760A501.3070504@alliedtelesis.co.nz>
 <20160617102429.GH7698@gauss.secunet.com>
 <20160618050336.GA12205@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Blair Steven <Blair.Steven@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:33697 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754567AbcFTK7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 06:59:38 -0400
Content-Disposition: inline
In-Reply-To: <20160618050336.GA12205@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 18, 2016 at 01:03:36PM +0800, Herbert Xu wrote:
> On Fri, Jun 17, 2016 at 12:24:29PM +0200, Steffen Klassert wrote:
> > On Wed, Jun 15, 2016 at 12:44:54AM +0000, Blair Steven wrote:
> > > The restoration is happening - but being actioned on the wrong location.
> > > 
> > > The destination IP address is being saved and restored, and the SPI 
> > > being written directly after the destination IP address. From my 
> > > understanding though, the ESN shuffling should have saved and restored 
> > > the UDP source / dest ports + SPI.
> > 
> > Yes, looks like we copy with a wrong offset if udp encapsulation
> > is used, skb_transport_header() does not point to the esp header
> > in this case. Ccing Herbert, he changed this part when switching
> > to the new AEAD interface with
> > commit 7021b2e1cddd ("esp4: Switch to new AEAD interface").
> 
> Thanks for catching this!
> 
> I think rather than changing the transport header (which isn't
> quite right because UDP still is the transport protocol), we can
> just save the offset locally.  Something like this:
> 
> ---8<---
> Blair Steven noticed that ESN in conjunction with UDP encapsulation
> is broken because we set the temporary ESP header to the wrong spot.
> 
> This patch fixes this by first of all using the right spot, i.e.,
> 4 bytes off the real ESP header, and then saving this information
> so that after encryption we can restore it properly.
> 
> Fixes: 7021b2e1cddd ("esp4: Switch to new AEAD interface")
> Reported-by: Blair Steven <Blair.Steven@alliedtelesis.co.nz>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good.
Blair could you please test this?

Thanks!
