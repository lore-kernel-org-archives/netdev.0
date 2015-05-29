From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 0/3] DSA: Support multiple CPU ports
Date: Fri, 29 May 2015 21:13:31 +0200
Message-ID: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>, mathieu@codeaurora.org,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48125 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756615AbbE2TTD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 15:19:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an RFC set of patches to support multiple CPU ports
in a DSA setup.

In the kirkwood DIR665 example, host eth1 is used for traffic to/from
ports lan4, lan2 and wan, where as all other ports use eth0.

RFC because it needs more testing and it would be nice to know if the
basic idea is applicable to SF2, etc.

Andrew Lunn (3):
  net: dsa: Refactor DT probing of a switch port
  dsa: Add support for multiple cpu ports.
  kirkwood: dir665: Enable the second Ethernet to the Switch

 Documentation/devicetree/bindings/net/dsa/dsa.txt |  66 ++++++++-
 arch/arm/boot/dts/kirkwood-dir665.dts             |  22 ++-
 drivers/net/dsa/mv88e6xxx.c                       |   8 +-
 include/net/dsa.h                                 |  28 +++-
 net/dsa/dsa.c                                     | 166 ++++++++++++++++------
 net/dsa/dsa_priv.h                                |   6 +
 net/dsa/slave.c                                   |  10 +-
 net/dsa/tag_brcm.c                                |   2 +-
 net/dsa/tag_dsa.c                                 |   2 +-
 net/dsa/tag_edsa.c                                |   2 +-
 net/dsa/tag_trailer.c                             |   2 +-
 11 files changed, 260 insertions(+), 54 deletions(-)

-- 
2.1.4
