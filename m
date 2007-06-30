From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: PM policy, hotplug, power saving and WoL
Date: Sat, 30 Jun 2007 15:31:23 -0300
Message-ID: <20070630183123.GB25474@khazad-dum.debian.net>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <20070630120541.GA21339@srcf.ucam.org> <46866C6B.9010801@linux.intel.com> <468687DE.6030003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	=?iso-8859-1?B?VPZy9ms=?= Edvin <edwintorok@gmail.com>,
	netdev@vger.kernel.org, power@bughost.org, zambrano@broadcom.com,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2.smtp.messagingengine.com ([66.111.4.26]:33123 "EHLO
	out2.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753185AbXF3Sb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 14:31:26 -0400
Content-Disposition: inline
In-Reply-To: <468687DE.6030003@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 30 Jun 2007, Jeff Garzik wrote:
> Like SATA, we actually want to support BOTH -- active hotplug and PHY 
> power-down -- and so this wanders into power management policy.
>
> Give me a knob, and we can program plenty of ethernet|SATA|USB|... drivers 
> to power down the PHY and save power.

While at it, could we please fix our borked WOL interface requirements, so
that the PHY is *never* to be powered down when WOL is active?  This is
another deficiency that userspace has to work around in halt(8)...

If WOL is enabled and supported in a device, the kernel must never do
anything that would cause that device to stop responding to WOL packets.

OTOH, if WOL is disabled, it would be very very nice indeed to be able to
tell the kernel that yes, it is to power down the PHY if it is not in use.
Laptops appreciate it a lot, and so do the switches (which will know they
don't have to forward any traffic over that port).

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
