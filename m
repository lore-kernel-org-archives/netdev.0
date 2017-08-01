From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v2 net-next 0/3] Refactor lan9303_xxx_packet_processing
Date: Tue,  1 Aug 2017 13:14:36 +0200
Message-ID: <20170801111439.1143-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is purely non functional. It changes the 
lan9303_enable_packet_processing,
lan9303_disable_packet_processing() to pass port number (0,1,2) as
parameter instead of port offset. This aligns them with
other functions in the module, and makes it possible to simplify the code.

First patch: Change lan9303_xxx_packet_processing parameter:
 - Pass port number (0,1,2) as parameter.
 - Introduced lan9303_write_switch_port() 
 - Plus replaced a constant 0x400 with LAN9303_SWITCH_PORT_REG()

Second patch: Introduce LAN9303_NUM_PORTS=3, used in next patch.

Third patch: Simplify lan9303_xxx_packet_processing usage.

Comments welcome!

Changes v1 -> v2:
 - introduced lan9303_write_switch_port() in first patch
 - inserted LAN9303_NUM_PORTS patch
 - Use LAN9303_NUM_PORTS in last patch. Plus whitespace change.  

Egil Hjelmeland (3):
  net: dsa: lan9303: Refactor lan9303_xxx_packet_processing()
  net: dsa: lan9303: define LAN9303_NUM_PORTS 3
  net: dsa: lan9303: Simplify lan9303_xxx_packet_processing() usage

 drivers/net/dsa/lan9303-core.c | 78 ++++++++++++++++++++++--------------------
 1 file changed, 40 insertions(+), 38 deletions(-)

-- 
2.11.0
