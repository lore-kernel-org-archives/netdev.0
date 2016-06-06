From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/5] net: dsa: misc improvements
Date: Mon,  6 Jun 2016 16:14:50 -0700
Message-ID: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33290 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcFFXPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:15:02 -0400
Received: by mail-pa0-f65.google.com with SMTP id di3so12682449pab.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 16:15:01 -0700 (PDT)
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

Most of the previous patches have been dropped to just keep the relevant ones
now.

Florian Fainelli (5):
  net: dsa: Provide unique DSA slave MII bus names
  net: dsa: Initialize ds->enabled_port_mask and ds->phys_mii_mask
  net: dsa: Add initialization helper for CPU port ethtool_ops
  net: dsa: Initialize CPU port ethtool ops per tree
  net: dsa: bcm_sf2: Register our slave MDIO bus

 drivers/net/dsa/bcm_sf2.c | 215 +++++++++++++++++++++++++++++-----------------
 drivers/net/dsa/bcm_sf2.h |   6 ++
 net/dsa/dsa.c             |  28 ++++++
 net/dsa/dsa2.c            |  31 +++++++
 net/dsa/dsa_priv.h        |   3 +
 net/dsa/slave.c           |  25 ++----
 6 files changed, 211 insertions(+), 97 deletions(-)

-- 
2.7.4
