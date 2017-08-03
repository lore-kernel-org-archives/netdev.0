From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v3 net-next 0/5] Refactor lan9303_xxx_packet_processing
Date: Thu,  3 Aug 2017 11:45:02 +0200
Message-ID: <20170803094507.3439-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series is purely non functional. 

It changes the lan9303_enable_packet_processing,
lan9303_disable_packet_processing() to pass port number (0,1,2) as
parameter instead of port offset. This aligns them with
other functions in the module, and makes it possible to simplify the code.

The lan9303_enable_packet_processing, lan9303_disable_packet_processing
functions operate on port. Therefore rename the functions to reflect that
as well.

Reviewer pointed out lan9303_get_ethtool_stats would be better off with
the use of a lan9303_read_switch_port(). So that was added to the series.

Review welcome!


Changes v2 -> v3:
 - Patch 1: Removed the change in lan9303_get_ethtool_stats
 - Added patch 4: rename lan9303_xxx_packet_processing 
 - Added patch 5: refactor lan9303_get_ethtool_stats
 
Changes v1 -> v2:
 - introduced lan9303_write_switch_port() in first patch
 - inserted LAN9303_NUM_PORTS patch
 - Use LAN9303_NUM_PORTS in last patch. Plus whitespace change.  

Egil Hjelmeland (5):
  net: dsa: lan9303: Change lan9303_xxx_packet_processing() port param.
  net: dsa: lan9303: define LAN9303_NUM_PORTS 3
  net: dsa: lan9303: Simplify lan9303_xxx_packet_processing() usage
  net: dsa: lan9303: Rename lan9303_xxx_packet_processing()
  net: dsa: lan9303: refactor lan9303_get_ethtool_stats

 drivers/net/dsa/lan9303-core.c | 110 ++++++++++++++++++++++-------------------
 1 file changed, 59 insertions(+), 51 deletions(-)

-- 
2.11.0
