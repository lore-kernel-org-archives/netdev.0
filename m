From: Arthur Jones <arthur.jones@riverbed.com>
Subject: Re: [PATCH] e1000e: workaround missing power down mii control bit
 on 82571
Date: Thu, 16 Dec 2010 14:14:21 -0800
Message-ID: <20101216221421.GR18990@ajones-laptop.nbttech.com>
References: <20101216182847.GA14985@ajones-laptop.nbttech.com>
 <1292525797.3253.8.camel@bwh-desktop>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7655@orsmsx509.amr.corp.intel.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F76C4@orsmsx509.amr.corp.intel.com>
 <20101216200425.GO18990@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([208.70.196.44]:39274 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753572Ab0LPWOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:14:22 -0500
Content-Disposition: inline
In-Reply-To: <20101216200425.GO18990@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bruce, ...

On Thu, Dec 16, 2010 at 12:04:26PM -0800, Arthur Jones wrote:
> Hi Bruce, ...
> 
> On Thu, Dec 16, 2010 at 11:28:18AM -0800, Allan, Bruce W wrote:
> > >-----Original Message-----
> > >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> > >Behalf Of Allan, Bruce W
> > >Sent: Thursday, December 16, 2010 11:04 AM
> > >To: Ben Hutchings; Arthur Jones
> > >Cc: Kirsher, Jeffrey T; netdev@vger.kernel.org
> > >Subject: RE: [PATCH] e1000e: workaround missing power down mii control bit on
> > >82571
> > >
> > >>-----Original Message-----
> > >>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> > >>Behalf Of Ben Hutchings
> > >>Sent: Thursday, December 16, 2010 10:57 AM
> > >>To: Arthur Jones
> > >>Cc: Kirsher, Jeffrey T; netdev@vger.kernel.org
> > >>Subject: Re: [PATCH] e1000e: workaround missing power down mii control bit on
> > >>82571
> > >>
> > >>Adding this special case into MDIO access seems like a really nasty
> > >>hack.  Surely the callers that set the control register should take care
> > >>of this.
> > >>
> > >>Ben.
> > >
> > >Agreed.  I am setting up to repro now to see if it is an actual hardware
> > >issue or just a software bug; either way, this patch is not the correct
> > >approach and I'll follow up shortly.
> > >
> > >Bruce.
> > 
> > It's the reset in e1000_set_settings() which ignores that we had previously
> > powered off the Phy.  I'll go through the rest of the code and fix up this
> > and any other occurrences of similar issues properly.
> 
> Thanks for having a look!
> 
> We do a read-modify-write there of
> the PHY control register.  We take
> the rest of the bits as being good,
> but, for some reason we don't get the
> power down bit (always reads back
> zero).  Is this a known 82571 issue?
> On 82574, e.g., we seem to get the
> power down bit back when we read...

BTW:  The 802.3 spec seems to indicate
that this bit _should_ be readable even
when the PHY is powered down (i.e.  this
is a PHY bug)...

Arthur

> 
> Are you sure you want to spread that
> 82571 specific logic all over the driver?
> 
> Arthur
> 
> > 
> > Thanks for reporting this issue Arthur.
> > 
> > Bruce.
