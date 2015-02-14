From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/2] Indirect phy access for mv88e6171
Date: Sat, 14 Feb 2015 19:17:49 +0100
Message-ID: <1423937871-9180-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44421 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091AbbBNSU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Feb 2015 13:20:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches allow the mv88e6171 driver to access the port phys
using indirect addressing. Depending on pin strapping, the switch
either uses a single address on the host MDIO bus, requiring the port
phys are accessed indirectly, or the switch uses a number of addresses
on the host bus and the phys can be directly accessed.

The 370RD, the first supported platform to use the 6171 uses multiple
addresses, so this indirect mode was not required. However the
WRT1900AC has the switch configured to use a single address, and so
indirect access is needed.

The mv88e6352 already has all the needed code. Refactor it into the
shared mv88e6xxx and then use it in the mv88e6171 driver.

Tested on the 370RD and WRT1900AC.

It would be good if Guenter Roeck could test on his platform to ensure
i've not broken anything for the mv88e6352.

Andrew Lunn (2):
  net: dsa: mv88e6352: Refactor shareable code
  net: dsa: mv88e6171: Enable access to phys via internal mdio bus

 drivers/net/dsa/mv88e6171.c | 18 ++++++-----
 drivers/net/dsa/mv88e6352.c | 77 +++++++--------------------------------------
 drivers/net/dsa/mv88e6xxx.c | 53 +++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  6 ++++
 4 files changed, 81 insertions(+), 73 deletions(-)

-- 
2.1.4
