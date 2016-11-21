From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 0/3] net: bridge: Allow CPU port configuration
Date: Mon, 21 Nov 2016 11:09:22 -0800
Message-ID: <20161121190925.14530-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
        stephen@networkplumber.org, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@mellanox.com, idosch@mellanox.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35792 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752835AbcKUTKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 14:10:02 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so29310641pga.2
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 11:10:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series allows using the bridge master interface to configure
an Ethernet switch port's CPU/management port with different VLAN attributes than
those of the bridge downstream ports/members.

Jiri, Ido, Andrew, Vivien, please review the impact on mlxsw and mv88e6xxx, I
tested this with b53 and a mockup DSA driver.

Open questions:

- if we have more than one bridge on top of a physical switch, the driver
  should keep track of that and verify that we are not going to change
  the CPU port VLAN attributes in a way that results in incompatible settings
  to be applied

- if the default behavior is to have all VLANs associated with the CPU port
  be ingressing/egressing tagged to the CPU, is this really useful?

Florian Fainelli (3):
  net: bridge: Allow bridge master device to configure switch CPU port
  net: dsa: Propagate VLAN add/del to CPU port(s)
  net: dsa: b53: Remove CPU port specific VLAN programming

 drivers/net/dsa/b53/b53_common.c | 22 ++++++--------------
 net/bridge/br_vlan.c             | 28 ++++++++++++++++++++++---
 net/dsa/slave.c                  | 45 +++++++++++++++++++++++++++++-----------
 3 files changed, 64 insertions(+), 31 deletions(-)

-- 
2.9.3
