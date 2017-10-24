From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 0/2] net: dsa: lan9303: Learn addresses on CPU port when bridged
Date: Tue, 24 Oct 2017 11:35:13 +0200
Message-ID: <20171024093515.6749-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CPU transmit directly to port using tag, the LAN9303 does not
learn MAC addresses received on the CPU port into the ALR table.
ALR learning is performed only when transmitting using ALR lookup.

Solution:
If the two external ports are bridged and the packet is not STP BPDU,
then use ALR lookup to allow ALR learning on CPU port.
Otherwise transmit directly to port with STP state override.

The first patch moves struct lan9303 to include/linux/lan9303.h in order
to prepare for the second patch. 

Egil Hjelmeland (2):
  net: dsa: lan9303: Move struct lan9303 to include/linux/lan9303.h
  net: dsa: lan9303: Learn addresses on CPU port when bridged

 MAINTAINERS               |  1 +
 drivers/net/dsa/lan9303.h | 34 +---------------------------------
 include/linux/lan9303.h   | 35 +++++++++++++++++++++++++++++++++++
 net/dsa/tag_lan9303.c     | 23 ++++++++++++++++++++++-
 4 files changed, 59 insertions(+), 34 deletions(-)
 create mode 100644 include/linux/lan9303.h

-- 
2.11.0
