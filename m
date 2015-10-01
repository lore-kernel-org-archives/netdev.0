From: Jon Ringle <jon@ringle.org>
Subject: Re: [PATCH 1/2] regmap: Allow installing custom reg_update_bits
 function
Date: Thu, 1 Oct 2015 08:29:19 -0400 (EDT)
Message-ID: <alpine.DEB.2.10.1510010826450.21737@jring-w510-7m3g.gridpoint.com>
References: <1443681187-29505-1-git-send-email-jon@ringle.org> <20151001094424.GG15635@sirena.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:32893 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932255AbbJAM3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 08:29:37 -0400
In-Reply-To: <20151001094424.GG15635@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 1 Oct 2015, Mark Brown wrote:

> On Thu, Oct 01, 2015 at 02:33:06AM -0400, jon@ringle.org wrote:
> 
> > @@ -2509,6 +2510,10 @@ static int _regmap_update_bits(struct regmap *map, unsigned int reg,
> >  	int ret;
> >  	unsigned int tmp, orig;
> >  
> > +	if (map->reg_update_bits)
> > +		return map->reg_update_bits(map->bus_context, reg, mask, val,
> > +					    change, force_write);
> > +
> >  	ret = _regmap_read(map, reg, &orig);
> >  	if (ret != 0)
> >  		return ret;
> 
> This completely bypasses and therefore breaks the cache infrastructure.
> 

Hi Mark,

Right after sending the v2 patch, I realized that calling the 
custom reg_update_bits would only be applicable for registers that are 
marked as volatile. Would the following solution be acceptable (it would 
also simplify the regmap_update_bits in the encx24j600 driver):

	if (regmap_volatile(map, reg) && map->reg_update_bits) {
		return map->reg_update_bits(map->bus_context, reg, mask, 
		                            val, change, force_write);
		
The cache state should not matter for volatile registers, right?

-Jon
