From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Fix GRO for multiple page fragments
Date: Fri, 17 Apr 2009 15:03:30 +0100
Message-ID: <1239977010.5297.19.camel@deadeye.i.decadent.org.uk>
References: <1239905060.3203.28.camel@achroite>
	 <20090417.012759.184081814.davem@davemloft.net>
	 <20090417091433.GA1535@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57734 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757422AbZDQODf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 10:03:35 -0400
In-Reply-To: <20090417091433.GA1535@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-04-17 at 17:14 +0800, Herbert Xu wrote:
> On Fri, Apr 17, 2009 at 01:27:59AM -0700, David Miller wrote:
> >
> > I think the code still isn't right after your changes.
> > 
> > The intent seems to be to append frags from 'info' into the SKB,
> > so that it works even if the SKB already has some frags.
> > 
> > And being that cxgb3 is pretty well tested with GRO I'm suspicious
> > even moreso :-)
> > 
> > Herbert?
> 
> Ah, I'd replied via private email to Ben.  This whole loop no
> longer exists in net-next.  As for 2.6.30, the existing loop
> should be correct.

The loop is iterating forward, not backward, so why initialise frag to
point to the last fragment?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
