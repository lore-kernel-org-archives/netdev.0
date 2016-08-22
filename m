From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/4] Fix MV88E6131 tagging
Date: Mon, 22 Aug 2016 16:01:00 +0200
Message-ID: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Cc: Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40579 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754844AbcHVOMX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 10:12:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell has two different tagging protocols for frames passed to a
swicth. There is the older DSA and the newer EDSA. Somewhere along the
way, we broke support for switches which only support DSA, by trying
to configure them to use EDSA. These patches add back support for
switches which only support DSA, by allowing the drivers to
dynamically indicate the tagging protocol they support to the DSA
core. This needs to be dynamic since the mv88e6xxx has to support two
protocols.

Thanks go to Jamie Lentin for reporting the problem, helping debug it,
providing some of the fix, and testing.

Andrew Lunn (3):
  net: dsa: Allow the DSA driver to indicate the tag protocol
  net: dsa: mv88e6xxx: Fix support for DSA tagging for older switches.
  dsa: mv88e6xxx: Delete ppu timer when removing module

Jamie Lentin (1):
  net: mv88e6xxx: Enable PORT_CONTROL_FORWARD_UNKNOWN for DSA-tagged CPU
    ports

 drivers/net/dsa/b53/b53_common.c      |  7 +++-
 drivers/net/dsa/bcm_sf2.c             |  7 +++-
 drivers/net/dsa/mv88e6060.c           |  7 +++-
 drivers/net/dsa/mv88e6xxx/Kconfig     |  1 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 61 +++++++++++++++++++++--------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 16 +++++++--
 include/net/dsa.h                     |  5 +--
 net/dsa/dsa.c                         |  5 ++-
 net/dsa/dsa2.c                        |  4 ++-
 9 files changed, 78 insertions(+), 35 deletions(-)

-- 
2.8.1
