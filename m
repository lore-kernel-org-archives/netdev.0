From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 03/12] bnx2x: correct usleep_range usage
Date: Wed, 23 Jan 2013 15:21:45 +0200
Message-ID: <1358947314-3851-4-git-send-email-yuvalmin@broadcom.com>
References: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1744 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755891Ab3AWOWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:22:16 -0500
In-Reply-To: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the incorrect usage of `usleep_range(1000, 1000)' into
`usleep_range(1000, 2000)'.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h   |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 10 +++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c    |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |  2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 3e4f3fa..9b6e27a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1224,7 +1224,7 @@ static inline int bnx2x_clean_tx_queue(struct bnx2x *bp,
 #endif
 		}
 		cnt--;
-		usleep_range(1000, 1000);
+		usleep_range(1000, 2000);
 	}
 
 	return 0;
@@ -1259,7 +1259,7 @@ static inline bool bnx2x_wait_sp_comp(struct bnx2x *bp, unsigned long mask)
 		}
 		netif_addr_unlock_bh(bp->dev);
 
-		usleep_range(1000, 1000);
+		usleep_range(1000, 2000);
 	}
 
 	smp_mb();
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c8158ba..e496f19 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -8654,7 +8654,7 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode, bool keep_link)
 	}
 
 	/* Give HW time to discard old tx messages */
-	usleep_range(1000, 1000);
+	usleep_range(1000, 2000);
 
 	/* Clean all ETH MACs */
 	rc = bnx2x_del_all_macs(bp, &bp->sp_objs[0].mac_obj, BNX2X_ETH_MAC,
@@ -9078,7 +9078,7 @@ static int bnx2x_er_poll_igu_vq(struct bnx2x *bp)
 		if (pend_bits == 0)
 			break;
 
-		usleep_range(1000, 1000);
+		usleep_range(1000, 2000);
 	} while (cnt-- > 0);
 
 	if (cnt <= 0) {
@@ -9113,7 +9113,7 @@ static int bnx2x_process_kill(struct bnx2x *bp, bool global)
 		    (pgl_exp_rom2 == 0xffffffff) &&
 		    (!CHIP_IS_E3(bp) || (tags_63_32 == 0xffffffff)))
 			break;
-		usleep_range(1000, 1000);
+		usleep_range(1000, 2000);
 	} while (cnt-- > 0);
 
 	if (cnt <= 0) {
@@ -9146,7 +9146,7 @@ static int bnx2x_process_kill(struct bnx2x *bp, bool global)
 	/* Wait for 1ms to empty GLUE and PCI-E core queues,
 	 * PSWHST, GRC and PSWRD Tetris buffer.
 	 */
-	usleep_range(1000, 1000);
+	usleep_range(1000, 2000);
 
 	/* Prepare to chip reset: */
 	/* MCP */
@@ -10917,7 +10917,7 @@ static int bnx2x_get_hwinfo(struct bnx2x *bp)
 
 			while (tout && REG_RD(bp, IGU_REG_RESET_MEMORIES)) {
 				tout--;
-				usleep_range(1000, 1000);
+				usleep_range(1000, 2000);
 			}
 
 			if (REG_RD(bp, IGU_REG_RESET_MEMORIES)) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index c0e0359..4a28601 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -325,7 +325,7 @@ static inline int bnx2x_state_wait(struct bnx2x *bp, int state,
 			return 0;
 		}
 
-		usleep_range(1000, 1000);
+		usleep_range(1000, 2000);
 
 		if (bp->panic)
 			return -EIO;
@@ -1407,7 +1407,7 @@ static int bnx2x_wait_vlan_mac(struct bnx2x *bp,
 
 		/* Wait until there are no pending commands */
 		if (!bnx2x_exe_queue_empty(exeq))
-			usleep_range(1000, 1000);
+			usleep_range(1000, 2000);
 		else
 			return 0;
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 18c2e61..1069669 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -212,7 +212,7 @@ static int bnx2x_stats_comp(struct bnx2x *bp)
 			break;
 		}
 		cnt--;
-		usleep_range(1000, 1000);
+		usleep_range(1000, 2000);
 	}
 	return 1;
 }
-- 
1.8.1.227.g44fe835
