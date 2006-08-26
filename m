From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] ethtool v4: add autoneg advertise feature
Date: Fri, 25 Aug 2006 20:58:07 -0400
Message-ID: <20060825205807.0af2f721.billfink@mindspring.com>
References: <9929d2390608240822w7a586d7ai679d2af0be7c7213@mail.gmail.com>
	<1551EAE59135BE47B544934E30FC4FC093FAA2@NT-IRVA-0751.brcm.ad.broadcom.com>
	<20060825194254.7657318f.billfink@mindspring.com>
	<9929d2390608251728u3c182abcya76e3139b82101a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	davem@davemloft.net, john.ronciak@intel.com,
	jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:14766 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net") by vger.kernel.org with ESMTP
	id S1422899AbWHZA6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 20:58:11 -0400
To: "Jeff Kirsher" <tarbal@gmail.com>
In-Reply-To: <9929d2390608251728u3c182abcya76e3139b82101a1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Aug 2006, Jeff Kirsher wrote:

> On 8/25/06, Bill Fink <billfink@mindspring.com> wrote:
> >
> > I agree.  Something like:
> >
> >         ethtool -s ethx auto on advertise mode1+mode2+...+moden
> >
> > For example:
> >
> >         ethtool -s ethx auto on advertise 100-half+100-full
> >
> > to set speed 100 either half or full duplex.
> >
> > Maybe have some abbreviations such as 100-all (same as above) or
> > all-half (for all supported half duplex) or just all (for all supported
> > modes), which I suppose is the default.
> >
> > Just an idea.
> >
> >                                                 -Bill
> >
> 
> I agree that using a hex value is less intuitive, but with proper
> documentation in the man file it would be easily understood.  It is
> also easier to state
> ethtool -s ethx autoneg on advertise 0x0F
> than it would be to do:
> ethtool -s ethx autoneg on advertise 100-half+100-full+10-half+10-full

This could be abbreviated to:

	ethtool -s ethx autoneg on advertise 100-all+10-all

> Not that it is impossible to do, but the code to do the parsing would
> not be as clean as it is to use a hex value.  Currently ethtool
> already uses numeric values for messagelevel, phyad and sopass.  So I
> am not suggesting something completely new.  I have already submitted
> a patch to keep the old functionality while adding the new.  Only
> thing left for this is to create the manual documentation so that
> users can easily understand how to use the functionality.
> 
> 10-half     = 0x01
> 10-full      = 0x02
> 100-half   = 0x04
> 100-full    = 0x08
> 1000-half = 0x10 (actually not supported by IEEE standards)

I thought the above wasn't a supported option.

> 1000-full  = 0x20
> auto        = 0x00 or 0x3F
> 
> In addition the code already tests the value that the user enters with
> what is supported and only displays the supported values.

I agree that with decent documentation, use of the hex values shouldn't
be that difficult for most users, although using hex arithmetic might
be Greek to some.  I was just suggesting a possible alternative, but
I admit it's a fairly minor issue one way or the other.

						-Bill
