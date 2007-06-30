From: Jeff Garzik <jeff@garzik.org>
Subject: PM policy, hotplug, power saving (was Re: [PATCH] b44: power down
 PHY when interface down)
Date: Sat, 30 Jun 2007 12:42:06 -0400
Message-ID: <468687DE.6030003@garzik.org>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <20070630120541.GA21339@srcf.ucam.org> <46866C6B.9010801@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Garrett <mjg59@srcf.ucam.org>,
	=?ISO-8859-1?Q?T=F6r=F6k_Edv?= =?ISO-8859-1?Q?in?=
	<edwintorok@gmail.com>, netdev@vger.kernel.org, power@bughost.org,
	zambrano@broadcom.com, linux-kernel@vger.kernel.org
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37020 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756267AbXF3QmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jun 2007 12:42:13 -0400
In-Reply-To: <46866C6B.9010801@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Matthew Garrett wrote:
>> Do you still get link beat detection when the phy is powered down?

> does that matter?
> If the interface is down, nic drivers aren't expected to detect link... 
> if userspace wants to find link status it should have the interface up.


Definitely matters.  Switch renegotiation can take a while, and you must 
take into account the common case of interface bouncing (immediate down, 
then up).

Hoards actively complained the few times we experimented with this, 
because of e.g. DHCP's habit of bouncing the interface, which resulted 
in PHY power bouncing, which resulted in negotiation, which resulted in 
an excrutiating wait on various broken or stupid switches.

Overall, this may be classed with other problems of a similar sort:  we 
can power down a PHY, but that removes hotplug capability and extends 
partner/link negotiation time.

Like SATA, we actually want to support BOTH -- active hotplug and PHY 
power-down -- and so this wanders into power management policy.

Give me a knob, and we can program plenty of ethernet|SATA|USB|... 
drivers to power down the PHY and save power.

	Jeff


