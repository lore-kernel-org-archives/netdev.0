From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 13:46:18 -0800 (PST)
Message-ID: <20081112.134618.30673281.davem@davemloft.net>
References: <20081112.035240.226243372.davem@davemloft.net>
	<20081112.041143.11487260.davem@davemloft.net>
	<1226494493.3016.3.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57599
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751298AbYKLVqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 16:46:18 -0500
In-Reply-To: <1226494493.3016.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 12 Nov 2008 12:54:53 +0000

> On Wed, 2008-11-12 at 04:11 -0800, David Miller wrote:
> [...]
> > So the following patch should fix this bug.  writeq() should
> > be OK as-is, so doesn't need a similar change.
> > 
> > diff --git a/drivers/net/niu.c b/drivers/net/niu.c
> > index 9acb5d7..d8463b1 100644
> > --- a/drivers/net/niu.c
> > +++ b/drivers/net/niu.c
> > @@ -51,8 +51,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
> >  #ifndef readq
> >  static u64 readq(void __iomem *reg)
> >  {
> > -	return (((u64)readl(reg + 0x4UL) << 32) |
> > -		(u64)readl(reg));
> > +	return ((u64) readl(reg)) | (((u64) readl(reg + 4UL)) << 32);
> >  }
> 
> Since there's no sequence point between the reads, there's no guarantee
> that the reads happen in the order written (regardless of barriers
> inside readl()).  This needs to be split into two statements.

What version of the C language are you using?

I personally think it's safe.  If the compiler sees "A | B" it's going
to emit the code to compute A, then the code to emit B, and finally
the "|" operation.

Everything I've always seen says that for "|" the expressions are
evaluated left to right.
