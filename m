From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 02/18] e1000: Remove DISABLE_MULR debug code
Date: Wed, 01 Nov 2006 09:51:33 -0800
Message-ID: <20061101175132.2356.7491.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:14864 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946962AbWKARmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:42:55 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Remove debugging code disabling MULR (multiple reads). It's not usable
for a wide audience and there are no known problems with MULR right
now.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7ec2dd5..d3224c8 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -602,9 +602,6 @@ void
 e1000_reset(struct e1000_adapter *adapter)
 {
 	uint32_t pba, manc;
-#ifdef DISABLE_MULR
-	uint32_t tctl;
-#endif
 	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
 
 	/* Repartition Pba for greater than 9k mtu
@@ -671,12 +668,7 @@ e1000_reset(struct e1000_adapter *adapte
 	e1000_reset_hw(&adapter->hw);
 	if (adapter->hw.mac_type >= e1000_82544)
 		E1000_WRITE_REG(&adapter->hw, WUC, 0);
-#ifdef DISABLE_MULR
-	/* disable Multiple Reads in Transmit Control Register for debugging */
-	tctl = E1000_READ_REG(hw, TCTL);
-	E1000_WRITE_REG(hw, TCTL, tctl & ~E1000_TCTL_MULR);
 
-#endif
 	if (e1000_init_hw(&adapter->hw))
 		DPRINTK(PROBE, ERR, "Hardware Error\n");
 	e1000_update_mng_vlan(adapter);



---
Auke Kok <auke-jan.h.kok@intel.com>
