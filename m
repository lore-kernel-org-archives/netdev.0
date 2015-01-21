From: Vijay <katoch.vijay@gmail.com>
Subject: Re: PHYless ethernet switch MAC-MAC serdes connection
Date: Wed, 21 Jan 2015 07:09:45 +0000 (UTC)
Message-ID: <loom.20150121T075010-767@post.gmane.org>
References: <loom.20150120T140914-531@post.gmane.org> <54BE9B0B.7070507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59617 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbbAUHJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jan 2015 02:09:54 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1YDpQE-0007PT-AG
	for netdev@vger.kernel.org; Wed, 21 Jan 2015 08:09:51 +0100
Received: from 2024ob.scansafe.net ([115.111.223.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 08:09:50 +0100
Received: from katoch.vijay by 2024ob.scansafe.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 08:09:50 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli <at> gmail.com> writes:

> 
> Do lan1 and lan2 interfaces set the RUNNING flag, which would indicate
> that the switch driver has detected a carrier for these individual 
ports?
> 
> Is the DSA switch driver correctly polling for LAN ports link 
statuses?
> 

Yes RUNNING flag is set.
Whenever I unplug/plug Ethernet cable. I see notification from dsa about 
link up/down correctly.

> 
> DSA registers a slave MDIO bus interface which calls into the "real"
> MDIO bus hardware to talk to the switch. In your case, you have both 
an
> external switch and an external PHY connected to the same MDIO bus,
> which is fine.
> 
> Your DT looks sane, although I suspect that lan2's PHY address is 3, 
and
> not 2, as address 0 is typically a special MDIO broadcast address, so
> Port 0's PHY can be read at PHY addr 1, Port 1's PHY can be read at 
PHY
> addr 2 etc... If you remove "lan2", does it work slightly better?
> 

No, lan 1 and lan2 addresses are 0 and 1 respectively. I have logged 
these values and these are printed on console as:

DSA: dsa.c: Init slave bus
DSA: slave.c: dsa_slave_mii_bus_init sw addr =0x1f , slave_mii_bus_id = 
0x0
DSA: dsa.c: register created slave_mii_bus
Debug: drivers/net/phy/phy_device.c: Creating PHY-> phy_id = 0x1410c89, 
addr = 0x0
Creating PHY-> AUTONEG_ENABLE for phy_id = 0x1410c89, addr = 0x0
Debug: drivers/net/phy/phy_device.c: Creating PHY-> phy_id = 0x1410c89, 
addr = 0x1
Creating PHY-> AUTONEG_ENABLE for phy_id = 0x1410c89, addr = 0x1
libphy: dsa slave smi: probed
net lan1: PHY already attached
DSA: slave.c: mii_bus-> name = dsa slave smi , id =dsa-0:1f
net lan2: PHY already attached
DSA: slave.c: mii_bus-> name = dsa slave smi , id =dsa-0:1f

My eth0 fixed-link address is also 0 and eth1 PHY address is 1.

Removing lan2 is not improving the situation.
Even if I do not set up eth1. Then same issue is happening between lan1 
and lan2. Whichever is configured first ( using ifconfig) is able to 
transmit packet (Tx increments). And rest all ports ( lan2) are just 
receiving (their Tx counters remain 0). Even if I ping to lan2 ip, 
response will be received only when ethernet cable is plugged to lan1 ( 
because it will only be able transmit the response), It does not matter 
if cable is plugged to lan2 port.
