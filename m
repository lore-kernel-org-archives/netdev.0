From: Gerlando Falauto <gerlando.falauto@keymile.com>
Subject: Disabling autoneg and enforcing speed/duplex
Date: Thu, 06 Feb 2014 13:00:43 +0100
Message-ID: <52F3796B.8050809@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"Brunck, Holger" <Holger.Brunck@keymile.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:44011 "EHLO
	mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027AbaBFMHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 07:07:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm using the Kirkwood Ethernet controller (mv643xx_eth.c) with a 
Marvell 88E3018 PHY which needs to be set in forced 100Base-TX mode.

Thanks to Sebastian's addition of DT support to the ethernet driver, I 
can easily set speed and duplex within the ethernet's port node, 
therefore leaving the phy unmanaged -- this works fine (I guess this 
mode is set on the phy by the bootloader or by strap settings).

However, this PHY has an erratum whose workaround requires some 
registers be written -- I believe the natural solution would be to start 
managing the PHY (i.e. set "phy-handle") and implement the proper 
workaround within drivers/net/phy/marvell.c. Making the PHY managed does 
however enable autoneg and therefore break everything.

Which brings me to my question: shouldn't there be a way to specify some 
forced settings within the PHY's node for such cases?

Only thing I found vaguely resembling what I'm looking for is Florian's 
patch introducing "max-speed" in the PHY -- not quite the same thing 
though. Which, if I understand it correctly, implements it as a property 
of the PHY, whereas ePAPR specifies it as a property of the ethernet 
device (which makes sense, since you might want to connect a 10/100 MII 
to a 10/100/1000 PHY and therefore have the MII restrict the 
capabilities of the PHY).

Or perhaps I'm missing some important bits here?

Thanks!
Gerlando
