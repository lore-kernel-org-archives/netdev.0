From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: mv643xx_eth: use {readl|writel}_relaxed instead
 of readl/writel
Date: Fri, 13 May 2016 17:24:31 +0200
Message-ID: <20160513152431.GA4136@lunn.ch>
References: <1463140760-7128-1-git-send-email-jszhang@marvell.com>
 <1463140760-7128-2-git-send-email-jszhang@marvell.com>
 <3966837.tFk2PD8QFb@wuerfel>
 <20160513201955.256e5169@xhacker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org,
	sebastian.hesselbarth@gmail.com
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37684 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752063AbcEMPYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 11:24:37 -0400
Content-Disposition: inline
In-Reply-To: <20160513201955.256e5169@xhacker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 13, 2016 at 08:19:55PM +0800, Jisheng Zhang wrote:
> Dear Arnd,
> 
> On Fri, 13 May 2016 14:09:43 +0200 Arnd Bergmann wrote:
> 
> > On Friday 13 May 2016 19:59:19 Jisheng Zhang wrote:
> > >  /* port register accessors **************************************************/
> > >  static inline u32 rdl(struct mv643xx_eth_private *mp, int offset)
> > >  {
> > > -	return readl(mp->shared->base + offset);
> > > +	return readl_relaxed(mp->shared->base + offset);
> > >  }
> > >  
> > >  static inline u32 rdlp(struct mv643xx_eth_private *mp, int offset)
> > >  {
> > > -	return readl(mp->base + offset);
> > > +	return readl_relaxed(mp->base + offset);
> > >  }  
> > 
> > I'd recommend not changing these in general, but introducing new 'rdl_relaxed()'
> > and 'rdlp_relaxed()' etc variants that you use in the code that actually
> > is performance sensitive, but use the normal non-relaxed versions by
> > default.
> > 
> > Then add a comment to each use of the relaxed accessors on how you know
> > that it's safe for that caller. This usually is just needed for the xmit()
> > function and for the interrupt handler.
> 
> Got your points and I do think it makes sense. But could we always use the
> relaxed version to save some LoCs.

It is a trade off between lines of code and hard to find bugs. Getting
this wrong can introduce subtle bugs.

Best be paranoid and only touch the fast path, where this actually
matters.

     Andrew
