From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 13/18] e1000: Only set IDE for tx when we are using TIDV/TADV
Date: Wed, 01 Nov 2006 09:51:58 -0800
Message-ID: <20061101175158.2356.56760.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:21264 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946972AbWKARoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:44 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Spec fix: don't set IDE unless we are actually setting the tx
int delay time.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000/e1000_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 99dd6b9..db933bf 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1580,8 +1580,11 @@ e1000_configure_tx(struct e1000_adapter 
 	e1000_config_collision_dist(hw);
 
 	/* Setup Transmit Descriptor Settings for eop descriptor */
-	adapter->txd_cmd = E1000_TXD_CMD_IDE | E1000_TXD_CMD_EOP |
-		E1000_TXD_CMD_IFCS;
+	adapter->txd_cmd = E1000_TXD_CMD_EOP | E1000_TXD_CMD_IFCS;
+
+	/* only set IDE if we are delaying interrupts using the timers */
+	if (adapter->tx_int_delay)
+		adapter->txd_cmd |= E1000_TXD_CMD_IDE;
 
 	if (hw->mac_type < e1000_82543)
 		adapter->txd_cmd |= E1000_TXD_CMD_RPS;



---
Auke Kok <auke-jan.h.kok@intel.com>
