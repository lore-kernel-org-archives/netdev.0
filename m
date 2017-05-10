From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 00/12] drivers: net: xgene: Add ethtool stats and bug fixes
Date: Wed, 10 May 2017 13:44:58 -0700
Message-ID: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>,
        Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:38542 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdEJUmV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 16:42:21 -0400
Received: by mail-it0-f49.google.com with SMTP id e65so8948738ita.1
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:42:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set,

- adds ethtool extended statistics support
- addresses errata workarounds
- fixes bugs related to statistics

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---
v2: Address review comments from v1
	- Adds lock to protect mdio-xgene indirect MAC access
	- Refactors xgene-enet indirect MAC read/write functions
	- Uses mdio-xgene MAC access routines, if xgene-enet port
	  use the same HW.
v1:
	- Initial version
---

Iyappan Subramanian (3):
  drivers: net: xgene: Protect indirect MAC access
  drivers: net: xgene: Add rx_overrun/tx_underrun statistics
  drivers: net: xgene: Fix redundant prefetch buffer cleanup

Quan Nguyen (9):
  drivers: net: phy: xgene: Add lock to protect mac access
  drivers: net: xgene: Use rgmii mdio mac access
  drivers: net: xgene: Remove redundant local stats
  drivers: net: xgene: Refactor statistics error parsing code
  drivers: net: xgene: Remove unused macros
  drivers: net: xgene: Extend ethtool statistics
  drivers: net: xgene: Workaround for HW errata 10GE_4
  drivers: net: xgene: Add frame recovered statistics counter for errata
    10GE_8/ENET_11
  drivers: net: xgene: Workaround for HW errata 10GE_10/ENET_15

 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 132 ++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 188 +++++++++++----------
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  70 +++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |  59 +++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  12 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c  | 110 +++---------
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  |  77 +++------
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |   5 +
 drivers/net/phy/mdio-xgene.c                       |  74 ++++----
 drivers/net/phy/mdio-xgene.h                       |   3 +
 10 files changed, 428 insertions(+), 302 deletions(-)

-- 
1.9.1
