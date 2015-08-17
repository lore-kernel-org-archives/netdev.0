From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/3] D in DSA patches
Date: Mon, 17 Aug 2015 23:52:49 +0200
Message-ID: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Cc: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60887 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751050AbbHQWA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 18:00:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The D in DSA is distributed, meaning multiple switches can be
connected together. Currently no mainline system does this, and so the
code is broken. This patchset contains two fixes, and a small helper.

With three of more switches, the current device tree binding is not
sufficient to express the routing between the switches. The first
patch extends the binding, in a backwards compatible way, to allow a
link between a switch to describe all the switches accessible over the
link, not just the direct neighbor.

The third patch fixes the port configuration on newer devices for
links connecting switches.

Andrew Lunn (3):
  net: dsa: Allow multi hop routes to be expressed
  net: dsa: Add dsa_is_dsa_port() helper
  dsa: mv88e6xxx: Set DSA mode based on chip abilities

 Documentation/devicetree/bindings/net/dsa/dsa.txt | 33 +++++++++++++++----
 drivers/net/dsa/mv88e6xxx.c                       | 16 +++++----
 include/net/dsa.h                                 |  5 +++
 net/dsa/dsa.c                                     | 40 +++++++++++++++++------
 4 files changed, 71 insertions(+), 23 deletions(-)

-- 
2.5.0
