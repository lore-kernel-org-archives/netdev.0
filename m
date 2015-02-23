From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT/RFC PATCH 0/8] net: dsa: mv88e6xxx: Add support for HW bridging
Date: Mon, 23 Feb 2015 11:35:42 -0800
Message-ID: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:34239 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbBWTfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 14:35:54 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPynK-003fAE-8l
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 19:35:54 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series applies on top of net-next, plus Florian's patches
integrating dsa with SWITCHDEV for HW bridging. It also requires the patch
'net: dsa: Ensure that port array elements are initialized before being used'.

HW bridging support is currently only enabled for MV8865352, but it should be
straightforward to enable support for other Marvell chips by adding three lines
of initialization code to the respective source; see patch 8/8 for details.
mv886e3131.c would also have to use mv88e6xxx_setup_port_common(). 

Patches 1-3 prepare the mv88e6xxx code for adding HW bridging support.
Patch 4 adds core HW bridging support to the mv88e6xxx code. Patch 5-7
prepare the drivers for mv88e6352, mv88e6123_61_65, and mv88e6171 for
HW bridging support, without actually enabling it. Patch 8 enables
HW bridging support in the mv88e6352 driver.

Patches 5 and 8 could possibly be merged, but I thought it was better
to keep them separate because they logically serve a different purpose.

Testing has been minimal, and only with MV88E6352. Ports can be added to
and removed from a bridge, and I have been able to pass data through a port
configured as bridge port.
