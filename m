From: David Daney <ddaney@caviumnetworks.com>
Subject: RFD: OF device tree vs. PHY flags.
Date: Fri, 15 Oct 2010 11:18:00 -0700
Message-ID: <4CB89AD8.7020200@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Grant Likely <grant.likely@secretlab.ca>,
	devicetree-discuss@lists.ozlabs.org,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:5600 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932310Ab0JOSSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 14:18:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am in the process of planning a conversion of Octeon SOC platform code 
to use the OF device tree in the Linux kernel.

One issue that I have encountered, is that for some boards, we need to 
pass a non-zero flags argument to the phy_attach_direct() method.  The 
value of the flags is board dependent, so it would make some sense to 
encode its value in the device tree itself.  The flags I am interested 
in control the configuration of clocking modes and status LED connections.

I would suggest the following:

o Add a new property to "ethernet-phy" dts bindings called 
"linux,flags".  It would contain a comma separated string of flag names. 
  Something like "led-mode1,clock-mode2".  The semantics of the flag 
names would be interpreted by the PHY driver...

o Add a new function pointer to struct phy_driver: u32 
(*of_parse_flags)(struct phy_device *phydev).  This would parse and 
return the flags value for the "linux,flags" property from the 
device_node associated with the particular PHY device in question.

o Modify of_phy_connect() to do something like the following:

.
.
.
	if (phy->driver && phy->driver->of_parse_flags)
		flags |= phy->driver->of_parse_flags(phy);
.
.
.

o Perhaps add some helper functions to of_mdio.c to assist in parsing 
the "linux,flags" properties string.

o Any extra code in the PHY drivers and struct phy_driver would be 
protected by #ifdef CONFIG_OF

How does this sound?

Any suggestions as for improvements, or better names for things?


Thanks,
David Daney
