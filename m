From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net: enable dynamic lro disabling for vlans
Date: Tue, 24 May 2011 13:54:01 -0400
Message-ID: <20110524175401.GC28521@hmsreliant.think-freely.org>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
 <1306257769.17233.61.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48744 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757051Ab1EXRyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:54:06 -0400
Content-Disposition: inline
In-Reply-To: <1306257769.17233.61.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 10:22:49AM -0700, Ben Hutchings wrote:
> On Tue, 2011-05-24 at 13:15 -0400, Neil Horman wrote:
> > Hey there-
> > 	Noted recently that, while physical devices have lro disabled when
> > attached to a bridge, vlan devices do not.
> 
> Good point.
> 
> > This is because the vlan netdev has
> > no get/set flags method in its ethtool_ops struct. This series adds those
> > methods as passthrough calls to the underlying physical devices, so that whe
> > dev_disable_lro is called on a vlan device, the physical device underneath has
> > lro properly disabled.
> 
> But I don't think this is correct.
> 
> The get_flags() result should be masked with vlan_features.  And
> set_flags() shouldn't be allowed; the VLAN device should normally follow
> the parent device and not the other way round.  I think
I'm not sure thats entirely true (see vlan_ethtool_get_settings, it does a
passthrough to the physical device just like I'm doing, although you're correct
we don't do any passthrough of the set methods).

> dev_disable_lro() needs to handle VLAN devices explicitly, instead.
> 
I suppose that will work just as well as this, and likely will be more concise.
I'll respin shortly.

Best
Neil

> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
