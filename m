From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 0/4] MV88E6390 batch two
Date: Sat,  3 Dec 2016 04:35:15 +0100
Message-ID: <1480736119-12195-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38590 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753025AbcLCEKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 23:10:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second batch of patches adding support for the
MV88e6390. They are not sufficient to make it work properly.

The mv88e6390 has a much expanded set of priority maps. Refactor the
existing code, and implement basic support for the new device.

Similarly, the monitor control register has been reworked.

The mv88e6390 has something odd in its EDSA tagging implementation,
which means it is not possible to use it. So we need to use DSA
tagging. This is the first device with EDSA support where we need to
use DSA, and the code does not support this. So two patches refactor
the existing code. The two different register definitions are
separated out, and using DSA on an EDSA capable device is added.

v2:
Add port prefix
Add helper function for 6390
Add _IEEE_ into #defines
Split monitor_ctrl into a number of separate ops.
Remove 6390 code which is management, used in a later patch
s/EGREES/EGRESS/.
Broke up setup_port_dsa() and set_port_dsa() into a number of ops

v3:
Verify mandatory ops for port setup
Don't set ether type for DSA port.

Andrew Lunn (4):
  net: dsa: mv88e6xxx: Implement mv88e6390 tag remap
  net: dsa: mv88e6xxx: Monitor and Management tables
  net: dsa: mv88e6xxx: Move the tagging protocol into info
  net: dsa: mv88e6xxx: Refactor CPU and DSA port setup

 drivers/net/dsa/mv88e6xxx/chip.c      | 339 ++++++++++++++++++++++++++--------
 drivers/net/dsa/mv88e6xxx/global1.c   |  69 +++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |   4 +
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  62 +++++--
 drivers/net/dsa/mv88e6xxx/port.c      | 181 ++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |  15 ++
 6 files changed, 583 insertions(+), 87 deletions(-)

-- 
2.10.2
