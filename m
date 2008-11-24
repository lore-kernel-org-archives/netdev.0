From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/2] igb: loopback bits not correctly cleared from
	RCTL register
Date: Mon, 24 Nov 2008 15:49:03 -0800
Message-ID: <20081124234903.24515.58872.stgit@gitlost.lost>
References: <20081124234845.24515.6891.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:55157 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753863AbYKXXtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 18:49:21 -0500
In-Reply-To: <20081124234845.24515.6891.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change forces the bits to 0 by using an &= operation with an inverted
mask of all options instead of using an |= with a value of 0.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |    3 ++-
 drivers/net/igb/igb_main.c    |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 8e9d295..d5efbcc 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1339,8 +1339,9 @@ static int igb_setup_desc_rings(struct igb_adapter *adapter)
 	wr32(E1000_RDLEN(0), rx_ring->size);
 	wr32(E1000_RDH(0), 0);
 	wr32(E1000_RDT(0), 0);
+	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
 	rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SZ_2048 |
-		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
+		E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 	wr32(E1000_RCTL, rctl);
 	wr32(E1000_SRRCTL(0), 0);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ae65fae..ab37ab0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1779,9 +1779,9 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	rctl = rd32(E1000_RCTL);
 
 	rctl &= ~(3 << E1000_RCTL_MO_SHIFT);
+	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
 
-	rctl |= E1000_RCTL_EN | E1000_RCTL_BAM |
-		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
+	rctl |= E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 
 	/*

