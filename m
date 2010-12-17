From: Arthur Jones <arthur.jones@riverbed.com>
Subject: Re: [PATCH] e1000e: workaround missing power down mii control bit
 on 82571
Date: Fri, 17 Dec 2010 06:04:53 -0800
Message-ID: <20101217140453.GS18990@ajones-laptop.nbttech.com>
References: <20101216182847.GA14985@ajones-laptop.nbttech.com>
 <1292525797.3253.8.camel@bwh-desktop>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7655@orsmsx509.amr.corp.intel.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F76C4@orsmsx509.amr.corp.intel.com>
 <20101216200425.GO18990@ajones-laptop.nbttech.com>
 <20101216221421.GR18990@ajones-laptop.nbttech.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7AD6@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from incomingmail.riverbed.com ([208.70.196.45]:4075 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754813Ab0LQOEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 09:04:55 -0500
Content-Disposition: inline
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A9001773F7AD6@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bruce, ...

On Thu, Dec 16, 2010 at 05:46:02PM -0800, Allan, Bruce W wrote:
> >-----Original Message-----
> >From: Arthur Jones [mailto:arthur.jones@riverbed.com]
> >Sent: Thursday, December 16, 2010 2:14 PM
> >To: Allan, Bruce W
> >Cc: Ben Hutchings; Kirsher, Jeffrey T; netdev@vger.kernel.org
> >Subject: Re: [PATCH] e1000e: workaround missing power down mii control bit on
> >82571
> >
> >> > It's the reset in e1000_set_settings() which ignores that we had previously
> >> > powered off the Phy.  I'll go through the rest of the code and fix up this
> >> > and any other occurrences of similar issues properly.
> >>
> >> Thanks for having a look!
> >>
> >> We do a read-modify-write there of
> >> the PHY control register.  We take
> >> the rest of the bits as being good,
> >> but, for some reason we don't get the
> >> power down bit (always reads back
> >> zero).  Is this a known 82571 issue?
> >> On 82574, e.g., we seem to get the
> >> power down bit back when we read...
> >
> >BTW:  The 802.3 spec seems to indicate
> >that this bit _should_ be readable even
> >when the PHY is powered down (i.e.  this
> >is a PHY bug)...
> >
> >Arthur
> >
> >>
> >> Are you sure you want to spread that
> >> 82571 specific logic all over the driver?
> >>
> >> Arthur
> 
> No, not a PHY bug.  One difference between 82571 and 82574 is during a
> hardware reset (which is done by the ethtool command in your example
> repro case), the reset on 82571 is a much more aggressive reset than on
> 82574 which causes the bit to be cleared automatically.

That's not what I saw.  I saw the bit always
read back zero, even right after I set it.

Have you tried writing the power down bit and
reading it back?

Arthur

