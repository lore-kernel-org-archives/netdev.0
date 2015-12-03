From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/4] Allow BATMAN to use hdlc-eth interfaces
Date: Thu,  3 Dec 2015 21:12:29 +0100
Message-ID: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	netdev <netdev@vger.kernel.org>,
	"B.A.T.M.A.N" <b.a.t.m.a.n@lists.open-mesh.net>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53059 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753392AbbLCUMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 15:12:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BATMAN works over Ethernet like interfaces. hdlc-eth provides the need
requirements. However, hdlc devices are often created as raw hdlc
devices, which batman cannot use, and are then be transmuted into
other types using sethdlc(1). Have the HDLC code emit
NETDEV_*_TYPE_CHANGE events when the type changes, and have BATMAN
react on these events.

Andrew Lunn (4):
  WAN: HDLC: Detach protocol before unregistering device
  WAN: HDLC: Call notifiers before and after changing device type
  ipv6: Only act upon NETDEV_*_TYPE_CHANGE if we have ipv6 addresses
  batman-adv: Act on NETDEV_*_TYPE_CHANGE events

 drivers/net/wan/hdlc.c          | 21 ++++++++++++++++++---
 drivers/net/wan/hdlc_cisco.c    |  1 +
 drivers/net/wan/hdlc_fr.c       |  1 +
 drivers/net/wan/hdlc_ppp.c      |  1 +
 drivers/net/wan/hdlc_raw.c      |  1 +
 drivers/net/wan/hdlc_raw_eth.c  |  1 +
 drivers/net/wan/hdlc_x25.c      |  1 +
 include/linux/hdlc.h            |  2 +-
 net/batman-adv/hard-interface.c |  4 +++-
 net/ipv6/addrconf.c             |  3 ++-
 10 files changed, 30 insertions(+), 6 deletions(-)

-- 
2.6.2
