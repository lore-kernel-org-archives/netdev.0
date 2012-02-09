From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] smsc95xx: add module parameter to turn off NIC
 status leds
Date: Thu, 9 Feb 2012 16:18:44 +0000
Message-ID: <1328804324.2562.6.camel@bwh-desktop>
References: <1328699332-9024-1-git-send-email-pmeerw@pmeerw.net>
	 <20120208.152624.1844477840327789365.davem@davemloft.net>
	 <alpine.DEB.2.01.1202091024250.8085@pmeerw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Peter Meerwald <pmeerw@pmeerw.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45000 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753981Ab2BIQSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 11:18:50 -0500
In-Reply-To: <alpine.DEB.2.01.1202091024250.8085@pmeerw.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-09 at 10:38 +0100, Peter Meerwald wrote:
> Hello David,
> 
> > > add module parameter to allow to turn off NIC status leds (link, 
> > > speed, activity); blinking LEDs are annoying outside the server room :)
> 
> > No.  Create a generic mechanism, perhaps via ethtool, for users to
> > configure something like this.
>  
> > Otherwise the next driver that wants to provide this kind of knob
> > will add yet another module parameter with yet another name, and
> > this kind of ad-hoc set of interfaces absolutely sucks for users.
> 
> I am not sure how many NICs provide that functionality, so a specific knob 
> seemed reasonable

I think this has been controllable on all the PHYs I've dealt with.
Generally they need to be adaptable to the requirements for different
boards.  So in theory this is generic.

However I just don't see this being a popular enough option for many
driver maintainers to implement it.  Those status LEDs are useful.  Put
a piece of tape over them if you don't like them. :-)  Or if you're
designing a board then put them somewhere out of the way (but your users
may hate you for it).

> I had a look at ethtool, there are ETHTOOL_GFLAGS and ETHTOOL_GPFLAGS (and 
> the respective setters) which could be used -- but noone seems to use 
> those for any purpose 
> 
> a private flag for LED control (via ETHTOOL_GPFLAGS) is pretty much the 
> same knob as a module parameter, so not an option

In my view it's slightly preferable because private flags are
per-device.  Not sure whether David would agree.

Ben.

> so the remaining option is to add something like ETHTOOL_GLEDCONTROL / 
> ETHTOOL_SLEDCONTROL with likely only one user (smsc95xx)
> 
> regards, p.
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
