From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/9] net: dsa: misc improvements
Date: Fri,  3 Jun 2016 17:05:20 -0700
Message-ID: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36178 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbcFDAFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:05:41 -0400
Received: by mail-pf0-f196.google.com with SMTP id 62so12610696pfd.3
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:05:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series builds on top of Andrew's "New DSA bind, switches as devices"
patch set and does the following:

- add support for the old DSA binding with the new dsa_register_switch() API
  which is needed by some platforms where the Device Tree is pretty much frozen

- add a few helper functions/goodies for net/dsa/dsa2.c to be as close as possible
  from net/dsa/dsa.c in terms of what drivers can expect, in particular the slave
  MDIO bus and the enabled_port_mask and phy_mii_mask

- fix the CPU port ethtools ops to work in a multiple tree setup since we can
  no longer assume a single tree is supported

- finally conver the bcm_sf2 driver to be a true platform device driver and
  slightly rework its internal vs. external MDIO bus indirect read/writes to
  be cleaner

Florian Fainelli (9):
  net: dsa: Prepare to support legacy DT binding
  net: dsa: Add support for parsing the old binding
  net: dsa: Provide unique DSA slave MII bus names
  net: dsa: Initialize ds->enabled_port_mask and ds->phys_mii_mask
  net: dsa: Export suspend/resume functions
  net: dsa: Add initialization helper for CPU port ethtool_ops
  net: dsa: Initialize CPU port ethtool ops per tree
  net: dsa: bcm_sf2: Make it a real platform device driver
  net: dsa: bcm_sf2: Register our slave MDIO bus

 drivers/net/dsa/bcm_sf2.c | 390 +++++++++++++++++++++++++++++-----------------
 drivers/net/dsa/bcm_sf2.h |   6 +
 include/net/dsa.h         |  14 ++
 net/dsa/dsa.c             |  35 ++++-
 net/dsa/dsa2.c            | 199 ++++++++++++++++++++---
 net/dsa/dsa_priv.h        |   3 +
 net/dsa/slave.c           |  25 ++-
 7 files changed, 491 insertions(+), 181 deletions(-)

-- 
2.7.4
