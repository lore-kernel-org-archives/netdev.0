From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] ethtool v4: add autoneg advertise feature
Date: Fri, 25 Aug 2006 19:42:54 -0400
Message-ID: <20060825194254.7657318f.billfink@mindspring.com>
References: <9929d2390608240822w7a586d7ai679d2af0be7c7213@mail.gmail.com>
	<1551EAE59135BE47B544934E30FC4FC093FAA2@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tarbal@gmail.com, jgarzik@pobox.com, Jeff@lime.pobox.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	john.ronciak@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:21222 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net") by vger.kernel.org with ESMTP
	id S1422923AbWHYXnW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:43:22 -0400
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FAA2@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Aug 2006, Michael Chan wrote:

> Jeff Kirsher wrote:
> 
> > The old way of setting autonegotiation was using the 
> > following command:
> > ethtool -s ethx speed 100 duplex full auto on
> > now the command would be
> > ethtool -s ethx auto on advertise 0x08
> > both commands would result in only advertising 100 FULL.
> > 
> > There still needs to be a change made to the man file to reflect the
> > change in the behavior of ethtool, which I have not done.  But this
> > patch will allow for greater flexibility in setting autonegotiation
> > speeds.
> 
> It is more flexible, but less intuitive.  The user now has to
> remember hex values instead of the more intuitive speed and
> duplex.  Perhaps we can keep the old method of using speed and
> duplex, while adding the new method of specifying hex values? 

I agree.  Something like:

	ethtool -s ethx auto on advertise mode1+mode2+...+moden

For example:

	ethtool -s ethx auto on advertise 100-half+100-full

to set speed 100 either half or full duplex.

Maybe have some abbreviations such as 100-all (same as above) or
all-half (for all supported half duplex) or just all (for all supported
modes), which I suppose is the default.

Just an idea.

						-Bill
