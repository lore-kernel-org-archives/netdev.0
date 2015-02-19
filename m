From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
 operations
Date: Wed, 18 Feb 2015 21:59:53 -0800
Message-ID: <20150219055953.GA14247@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-3-git-send-email-f.fainelli@gmail.com>
 <54E54EF3.9020802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:50160 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbbBSF76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 00:59:58 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YOK9V-002Xjq-3N
	for netdev@vger.kernel.org; Thu, 19 Feb 2015 05:59:57 +0000
Content-Disposition: inline
In-Reply-To: <54E54EF3.9020802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 18, 2015 at 06:48:19PM -0800, Florian Fainelli wrote:
> On 17/02/15 11:26, Florian Fainelli wrote:
> > Update the Broadcom Starfighter 2 switch driver to implement the
> > join/leave/stp_update callbacks required for basic hardware bridging
> > support.
> > 
> > There is not much to be done at the driver level but translating the
> > STP state from Linux to their HW values.
> > 
> > Joining a bridge means that the joining port and the other port members
> > need to be in the same VLAN membership as the CPU, while leaving the
> > bridge puts the port back into a separate VLAN membership with only the
> > CPU.
> 
> I found a couple additional issues while testing:
> 
> - manipulating UP/DOWN state of interfaces that are part of a bridge
> would not restore their bridge membership
> 
> - removing an interface from a bridge and bringing it back up would
> leave it in blocked state
> 
Is this a problem with your implementation for sf2 or a generic problem
with the first patch, such as some missing state transitions ?

For sf2, you might have to set the port state as well as the bridge
association in the port_setup function. That is of course just a
wild guess.

Thanks,
Guenter
