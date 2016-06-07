From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 0/6] net: dsa: misc improvements
Date: Tue,  7 Jun 2016 16:32:37 -0700
Message-ID: <1465342363-28055-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36015 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932545AbcFGXc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:32:59 -0400
Received: by mail-pa0-f67.google.com with SMTP id fg1so15096850pad.3
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 16:32:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series builds on top of Andrew's "New DSA bind, switches as devices"
patch set and does the following:

- add a few helper functions/goodies for net/dsa/dsa2.c to be as close as possible
  from net/dsa/dsa.c in terms of what drivers can expect, in particular the slave
  MDIO bus and the enabled_port_mask and phy_mii_mask

- fix the CPU port ethtools ops to work in a multiple tree setup since we can
  no longer assume a single tree is supported

- make the bcm_sf2 driver register its own MDIO bus, yet assign it to
  ds->slave_mii_bus for everything to work in net/dsa/slave.c wrt. PHY probing,
  this is a tad cleaner than what we have now

Changes in v2:

Most of the previous patches have been dropped to just keep the relevant ones
now.

Changes in v3:
- split the addition of the slave MII bus as a separate patch
- properly unwind all operations at the right place and right time (ethtool ops,
  slave MDIO bus
- fixed a few typos here and there

Changes in v4:
- removed superfluous dst agrument to dsa_cpu_port_ethtool_{setup,restore}

Florian Fainelli (6):
  net: dsa: Provide unique DSA slave MII bus names
  net: dsa: Initialize ds->enabled_port_mask and ds->phys_mii_mask
  net: dsa: Provide a slave MII bus if needed
  net: dsa: Add initialization helper for CPU port ethtool_ops
  net: dsa: Initialize CPU port ethtool ops per tree
  net: dsa: bcm_sf2: Register our slave MDIO bus

 drivers/net/dsa/bcm_sf2.c | 215 +++++++++++++++++++++++++++++-----------------
 drivers/net/dsa/bcm_sf2.h |   6 ++
 include/net/dsa.h         |   1 +
 net/dsa/dsa.c             |  41 +++++++++
 net/dsa/dsa2.c            |  36 ++++++++
 net/dsa/dsa_priv.h        |   5 ++
 net/dsa/slave.c           |  25 ++----
 7 files changed, 232 insertions(+), 97 deletions(-)

-- 
2.7.4
