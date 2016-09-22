From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/4] net: dsa: add port fast ageing
Date: Thu, 22 Sep 2016 16:49:20 -0400
Message-ID: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35036 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965090AbcIVUuI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 16:50:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today the DSA drivers are in charge of flushing the MAC addresses
associated to a port when its STP state changes from Learning or
Forwarding, to Disabled or Blocking or Listening.

This makes the drivers more complex and hides this generic switch logic.

This patchset introduces a new optional port_fast_age operation to
dsa_switch_ops, to move this logic to the DSA layer and keep drivers
simple. b53 and mv88e6xxx are updated accordingly.

Vivien Didelot (4):
  net: dsa: add port STP state helper
  net: dsa: add port fast ageing
  net: dsa: b53: implement DSA port fast ageing
  net: dsa: mv88e6xxx: implement DSA port fast ageing

 drivers/net/dsa/b53/b53_common.c | 31 ++++++++++-----------------
 drivers/net/dsa/mv88e6xxx/chip.c | 45 ++++++++++++++++++++--------------------
 include/net/dsa.h                |  2 ++
 net/dsa/slave.c                  | 35 ++++++++++++++++++++++++-------
 4 files changed, 64 insertions(+), 49 deletions(-)

-- 
2.10.0
