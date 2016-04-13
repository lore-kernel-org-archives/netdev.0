From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 0/7] DSA refactoring: set 1
Date: Wed, 13 Apr 2016 02:40:38 +0200
Message-ID: <1460508045-20254-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54358 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757189AbcDMAnE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2016 20:43:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There has been a long running effort to refractor DSA probing to make
the switches true linux devices. Here are a small collection of
patches moving in this direction. Most have been seen before.

We take a little step forward by passing the dsa device point to the
driver, thus allowing it to perform resource allocations using the
normal mechanisms. This device structure will later be replaced by the
devices own device structure.

Future patches will add a true driver probe function, so we rename the
current probe function, cleaning up the namespace.

phys_port_mask continually confuses me, thinking it is about PHYs. But
it is actually about ports enabled to the outside world. So rename it to
enabled_port_mask.

Lots more patches yet to follow, this is just doing some ground work.

v2:
  enabled_port_mask instread of user_port_masks
  Added Tested-by's and Reviewed-by.

Andrew Lunn (7):
  net: dsa: Pass the dsa device to the switch drivers
  net: dsa: Have the switch driver allocate there own private memory
  net: dsa: Remove allocation of driver private memory
  net: dsa: Keep the mii bus and address in the private structure
  net: dsa: Rename DSA probe function.
  dsa: Rename phys_port_mask to user_port_mask
  dsa: mv88e6xxx: Use bus in mv88e6xxx_lookup_name()

 drivers/net/dsa/bcm_sf2.c   | 24 +++++++++++++-------
 drivers/net/dsa/mv88e6060.c | 47 +++++++++++++++++++++++---------------
 drivers/net/dsa/mv88e6060.h | 11 +++++++++
 drivers/net/dsa/mv88e6123.c | 14 +++++++-----
 drivers/net/dsa/mv88e6131.c | 14 +++++++-----
 drivers/net/dsa/mv88e6171.c | 14 +++++++-----
 drivers/net/dsa/mv88e6352.c | 14 +++++++-----
 drivers/net/dsa/mv88e6xxx.c | 55 +++++++++++++++++++++++++++++++--------------
 drivers/net/dsa/mv88e6xxx.h | 17 +++++++++++---
 include/net/dsa.h           | 16 ++++++++-----
 net/dsa/dsa.c               | 19 +++++++++-------
 11 files changed, 166 insertions(+), 79 deletions(-)

-- 
2.7.0
