From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: PM policy, hotplug, power saving (was Re: [PATCH] b44: power
 down PHY when interface down)
Date: Sat, 30 Jun 2007 14:10:58 -0400
Message-ID: <20070630141058.4c678c37@oldman>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com>
	<20070630120541.GA21339@srcf.ucam.org>
	<46866C6B.9010801@linux.intel.com>
	<468687DE.6030003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	=?UTF-8?B?VMO2csO2aw==?= Edvin <edwintorok@gmail.com>,
	netdev@vger.kernel.org, power@bughost.org, zambrano@broadcom.com,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43383 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752552AbXF3SLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 14:11:22 -0400
In-Reply-To: <468687DE.6030003@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Jun 2007 12:42:06 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Arjan van de Ven wrote:
> > Matthew Garrett wrote:
> >> Do you still get link beat detection when the phy is powered down?
> 
> > does that matter?
> > If the interface is down, nic drivers aren't expected to detect link... 
> > if userspace wants to find link status it should have the interface up.
> 
> 
> Definitely matters.  Switch renegotiation can take a while, and you must 
> take into account the common case of interface bouncing (immediate down, 
> then up).
> 
> Hoards actively complained the few times we experimented with this, 
> because of e.g. DHCP's habit of bouncing the interface, which resulted 
> in PHY power bouncing, which resulted in negotiation, which resulted in 
> an excrutiating wait on various broken or stupid switches.
> 
> Overall, this may be classed with other problems of a similar sort:  we 
> can power down a PHY, but that removes hotplug capability and extends 
> partner/link negotiation time.
> 
> Like SATA, we actually want to support BOTH -- active hotplug and PHY 
> power-down -- and so this wanders into power management policy.
> 
> Give me a knob, and we can program plenty of ethernet|SATA|USB|... 
> drivers to power down the PHY and save power.
> 
> 	Jeff

We do have IFF_DORMANT, but almost no driver uses it. And most
certainly, the common applications wouldn't know how to use it.
