From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 0/3] net: dsa: integration with SWITCHDEV for HW bridging
Date: Tue, 24 Feb 2015 13:15:31 -0800
Message-ID: <1424812534-8936-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:45757 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbbBXVTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:19:23 -0500
Received: by pdjz10 with SMTP id z10so36075233pdj.12
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 13:19:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch set provides the DSA and SWITCHDEV integration bits together and
modifies the bcm_sf2 driver accordingly such that it works properly with HW
bridging.

Changes in v3:

- add back the null pointer check in dsa_slave_br_port_mask from Guenter
- slightly rework patch 1 commit message not to mention the function name
  we add in patch 2

Changes in v2:

- avoid a race condition in how DSA network devices are created, patch from
  Guenter Roeck
- provide a consistent and work STP state once a port leaves the bridge
- retain a bridge device pointer to properly flag port/bridge membership
- properly flush the ARL (Address Resolution Logic) in bcm_sf2.c
- properly retain port membership when individually bringing devices up/down
  while they are members of a bridge

We discussed on the mailing-list the possibility of standardizing a "fdb_flush"
operation for DSA switch drivers, looking at the Marvell and Broadcom switches,
I am not convinced this is practical or diserable as the terminologies vary
here, but there is nothing preventing us from doing it later.

Many thanks to Guenter and Andrew for both testing and providing feedback.

Thanks!

Florian Fainelli (2):
  net: dsa: integrate with SWITCHDEV for HW bridging
  net: dsa: bcm_sf2: add HW bridging support

Guenter Roeck (1):
  net: dsa: Ensure that port array elements are initialized before being
    used

 drivers/net/dsa/bcm_sf2.c      | 155 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/bcm_sf2.h      |   2 +
 drivers/net/dsa/bcm_sf2_regs.h |  15 ++++
 include/net/dsa.h              |  10 +++
 net/dsa/Kconfig                |   1 +
 net/dsa/dsa.c                  |  17 +++--
 net/dsa/dsa_priv.h             |   9 ++-
 net/dsa/slave.c                | 161 +++++++++++++++++++++++++++++++++++++++--
 8 files changed, 352 insertions(+), 18 deletions(-)

-- 
2.1.0
