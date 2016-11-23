From: Andrew Lunn <andrew@lunn.ch>
Subject: [[PATCH net-next RFC] 0/4] MV88E6390 batch two
Date: Thu, 24 Nov 2016 00:43:14 +0100
Message-ID: <1479944598-20372-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53435 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933483AbcKWXo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 18:44:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC only. Not for committing. They will conflict with the mv88e6097
support.

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

Andrew Lunn (4):
  net: dsa: mv88e6xxx: Implement mv88e6390 tag remap
  net: dsa: mv88e6xxx: Monitor and Management tables
  net: dsa: mv88e6xxx: Move the tagging protocol into info
  net: dsa: mv88e6xxx: Refactor CPU and DSA port setup

 drivers/net/dsa/mv88e6xxx/chip.c      | 195 +++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx/global1.c   |  55 ++++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |   3 +
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  40 ++++---
 drivers/net/dsa/mv88e6xxx/port.c      | 132 +++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |   7 ++
 6 files changed, 348 insertions(+), 84 deletions(-)

-- 
2.10.2
