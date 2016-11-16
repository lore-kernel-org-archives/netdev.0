From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/6] Fixes for the MV88e6xxx interrupt code
Date: Wed, 16 Nov 2016 01:56:50 +0100
Message-ID: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41243 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933205AbcKPA5d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 19:57:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt code was never tested with a board who's probing
resulted in an -EPROBE_DEFFERED. So the clean up paths never got
tested. I now do have -EPROBE_DEFFERED, and things break badly during
cleanup. These are the fixes.

This is fixing code in net-next.

Andrew Lunn (6):
  net: dsa: mv88e6xxx: Fix typos when removing g1 interrupts
  net: dsa: mv88e6xxx: Fix unconditional irq freeing
  net: dsa: mv88e6xxx: Mask g1 interrupts and free interrupt
  net: dsa: mv88e6xxx: Fix releasing for the global2 interrupts
  net: dsa: mv88e6xxx: Fix cleanup on error for g1 interrupt setup
  net: dsa: mv88e6xxx: Hold the mutex while freeing g1 interrupts

 drivers/net/dsa/mv88e6xxx/chip.c      | 58 ++++++++++++++++++++++++-----------
 drivers/net/dsa/mv88e6xxx/global2.c   | 25 ++++++++++-----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  1 +
 3 files changed, 58 insertions(+), 26 deletions(-)

-- 
2.10.2
