From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] Fixes for port refactoring
Date: Thu, 10 Nov 2016 15:43:59 +0100
Message-ID: <1478789041-16264-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34172 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933541AbcKJOpS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 09:45:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patches which refactored setting up the switch MACs introduced a
couple of regressions. The RGMII delays for a port can be set using
other mechanism than just phy-mode. Don't overwrite the delays unless
explicitly asked to. This broke my Armada 370 RD. Also, the mv88e6351
family supports setting RGMII delays, but is missing the necessary
entries in the ops structures to allow this.

These fixes are to patches currently in net-next. No need for stable
etc.

Andrew Lunn (2):
  net: dsa: mv88e6xxx: Don't modify RGMII delays when not RGMII mode
  net: dsa: mv88e6xxx: 6351 family also has RGMII delays

 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++++
 drivers/net/dsa/mv88e6xxx/port.c | 5 +++--
 2 files changed, 7 insertions(+), 2 deletions(-)

-- 
2.10.2
