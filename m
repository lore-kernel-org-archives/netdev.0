From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Fix GRO for multiple page fragments
Date: Fri, 17 Apr 2009 15:01:12 +0100
Message-ID: <1239976872.5297.15.camel@deadeye.i.decadent.org.uk>
References: <1239905060.3203.28.camel@achroite>
	 <20090417.012759.184081814.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57728 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752753AbZDQOBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 10:01:18 -0400
In-Reply-To: <20090417.012759.184081814.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-04-17 at 01:27 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Thu, 16 Apr 2009 19:04:20 +0100
> 
> > This loop over fragments in napi_fraginfo_skb() was "interesting".
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > This is not tested, as only cxgb3 will currently pass in multiple
> > fragments at the same time.  skb_shinfo(skb)->nr_frags would already be
> > 0 but it makes no sense to rely on that.  I hope I'm not missing some
> > subtlety...
> 
> I think the code still isn't right after your changes.
> 
> The intent seems to be to append frags from 'info' into the SKB,
> so that it works even if the SKB already has some frags.
[...]

This function is setting up a 'new' skb from the fragments it's given.
To avoid allocation overhead it recycles skbs via napi->skb if they are
merged (or otherwise discarded).  There should be no data attached to
the recycled skb.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
