From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/2] bnx2x: Remove local defines for %pM and mac address
Date: Mon,  8 Aug 2011 08:53:04 -0700
Message-ID: <ffcc4916e5e727ac480c62aefd3c4e8ab080317c.1312818707.git.joe@perches.com>
References: <cover.1312818707.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1312818707.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use %pM and mac address directly instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bnx2x/bnx2x.h      |    4 ---
 drivers/net/bnx2x/bnx2x_main.c |   14 +++++-------
 drivers/net/bnx2x/bnx2x_sp.c   |   41 ++++++++++++++++-----------------------
 3 files changed, 23 insertions(+), 36 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index c423504..5aac959 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -115,10 +115,6 @@ do {								 \
 		dev_info(&bp->pdev->dev, __fmt, ##__args);	 \
 } while (0)
 
-#define BNX2X_MAC_FMT		"%pM"
-#define BNX2X_MAC_PRN_LIST(mac)	(mac)
-
-
 #ifdef BNX2X_STOP_ON_ERROR
 void bnx2x_int_disable(struct bnx2x *bp);
 #define bnx2x_panic() do { \
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 1507091..173b258 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9315,9 +9315,8 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 				val = MF_CFG_RD(bp, func_ext_config[func].
 						    iscsi_mac_addr_lower);
 				bnx2x_set_mac_buf(iscsi_mac, val, val2);
-				BNX2X_DEV_INFO("Read iSCSI MAC: "
-					       BNX2X_MAC_FMT"\n",
-					       BNX2X_MAC_PRN_LIST(iscsi_mac));
+				BNX2X_DEV_INFO("Read iSCSI MAC: %pM\n",
+					       iscsi_mac);
 			} else
 				bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
 
@@ -9327,9 +9326,8 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 				val = MF_CFG_RD(bp, func_ext_config[func].
 						    fcoe_mac_addr_lower);
 				bnx2x_set_mac_buf(fip_mac, val, val2);
-				BNX2X_DEV_INFO("Read FCoE L2 MAC to "
-					       BNX2X_MAC_FMT"\n",
-					       BNX2X_MAC_PRN_LIST(fip_mac));
+				BNX2X_DEV_INFO("Read FCoE L2 MAC to %pM\n",
+					       fip_mac);
 
 			} else
 				bp->flags |= NO_FCOE_FLAG;
@@ -9384,9 +9382,9 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 	if (!is_valid_ether_addr(bp->dev->dev_addr))
 		dev_err(&bp->pdev->dev,
 			"bad Ethernet MAC address configuration: "
-			BNX2X_MAC_FMT", change it manually before bringing up "
+			"%pM, change it manually before bringing up "
 			"the appropriate network interface\n",
-			BNX2X_MAC_PRN_LIST(bp->dev->dev_addr));
+			bp->dev->dev_addr);
 }
 
 static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
diff --git a/drivers/net/bnx2x/bnx2x_sp.c b/drivers/net/bnx2x/bnx2x_sp.c
index df52f11..b4d9c16 100644
--- a/drivers/net/bnx2x/bnx2x_sp.c
+++ b/drivers/net/bnx2x/bnx2x_sp.c
@@ -707,9 +707,8 @@ static void bnx2x_set_one_mac_e2(struct bnx2x *bp,
 	bnx2x_vlan_mac_set_cmd_hdr_e2(bp, o, add, CLASSIFY_RULE_OPCODE_MAC,
 				      &rule_entry->mac.header);
 
-	DP(BNX2X_MSG_SP, "About to %s MAC "BNX2X_MAC_FMT" for "
-			 "Queue %d\n", (add ? "add" : "delete"),
-			 BNX2X_MAC_PRN_LIST(mac), raw->cl_id);
+	DP(BNX2X_MSG_SP, "About to %s MAC %pM for Queue %d\n",
+			 add ? "add" : "delete", mac, raw->cl_id);
 
 	/* Set a MAC itself */
 	bnx2x_set_fw_mac_addr(&rule_entry->mac.mac_msb,
@@ -801,9 +800,9 @@ static inline void bnx2x_vlan_mac_set_rdata_e1x(struct bnx2x *bp,
 	bnx2x_vlan_mac_set_cfg_entry_e1x(bp, o, add, opcode, mac, vlan_id,
 					 cfg_entry);
 
-	DP(BNX2X_MSG_SP, "%s MAC "BNX2X_MAC_FMT" CLID %d CAM offset %d\n",
-			 (add ? "setting" : "clearing"),
-			 BNX2X_MAC_PRN_LIST(mac), raw->cl_id, cam_offset);
+	DP(BNX2X_MSG_SP, "%s MAC %pM CLID %d CAM offset %d\n",
+			 add ? "setting" : "clearing",
+			 mac, raw->cl_id, cam_offset);
 }
 
 /**
@@ -2579,9 +2578,8 @@ static inline void bnx2x_mcast_hdl_pending_add_e2(struct bnx2x *bp,
 
 		cnt++;
 
-		DP(BNX2X_MSG_SP, "About to configure "BNX2X_MAC_FMT
-				 " mcast MAC\n",
-				 BNX2X_MAC_PRN_LIST(pmac_pos->mac));
+		DP(BNX2X_MSG_SP, "About to configure %pM mcast MAC\n",
+				 pmac_pos->mac);
 
 		list_del(&pmac_pos->link);
 
@@ -2702,9 +2700,8 @@ static inline void bnx2x_mcast_hdl_add(struct bnx2x *bp,
 
 		cnt++;
 
-		DP(BNX2X_MSG_SP, "About to configure "BNX2X_MAC_FMT
-				 " mcast MAC\n",
-				 BNX2X_MAC_PRN_LIST(mlist_pos->mac));
+		DP(BNX2X_MSG_SP, "About to configure %pM mcast MAC\n",
+				 mlist_pos->mac);
 	}
 
 	*line_idx = cnt;
@@ -2998,9 +2995,8 @@ static inline void bnx2x_mcast_hdl_add_e1h(struct bnx2x *bp,
 		bit = bnx2x_mcast_bin_from_mac(mlist_pos->mac);
 		BNX2X_57711_SET_MC_FILTER(mc_filter, bit);
 
-		DP(BNX2X_MSG_SP, "About to configure "
-				 BNX2X_MAC_FMT" mcast MAC, bin %d\n",
-				 BNX2X_MAC_PRN_LIST(mlist_pos->mac), bit);
+		DP(BNX2X_MSG_SP, "About to configure %pM mcast MAC, bin %d\n",
+				 mlist_pos->mac, bit);
 
 		/* bookkeeping... */
 		BIT_VEC64_SET_BIT(o->registry.aprox_match.vec,
@@ -3233,9 +3229,8 @@ static inline int bnx2x_mcast_handle_restore_cmd_e1(
 
 		i++;
 
-		  DP(BNX2X_MSG_SP, "About to configure "BNX2X_MAC_FMT
-				   " mcast MAC\n",
-				   BNX2X_MAC_PRN_LIST(cfg_data.mac));
+		  DP(BNX2X_MSG_SP, "About to configure %pM mcast MAC\n",
+				   cfg_data.mac);
 	}
 
 	*rdata_idx = i;
@@ -3270,9 +3265,8 @@ static inline int bnx2x_mcast_handle_pending_cmds_e1(
 
 			cnt++;
 
-			DP(BNX2X_MSG_SP, "About to configure "BNX2X_MAC_FMT
-					 " mcast MAC\n",
-					 BNX2X_MAC_PRN_LIST(pmac_pos->mac));
+			DP(BNX2X_MSG_SP, "About to configure %pM mcast MAC\n",
+					 pmac_pos->mac);
 		}
 		break;
 
@@ -3357,9 +3351,8 @@ static inline int bnx2x_mcast_refresh_registry_e1(struct bnx2x *bp,
 				&data->config_table[i].middle_mac_addr,
 				&data->config_table[i].lsb_mac_addr,
 				elem->mac);
-			DP(BNX2X_MSG_SP, "Adding registry entry for ["
-					 BNX2X_MAC_FMT"]\n",
-				   BNX2X_MAC_PRN_LIST(elem->mac));
+			DP(BNX2X_MSG_SP, "Adding registry entry for [%pM]\n",
+					 elem->mac);
 			list_add_tail(&elem->link,
 				      &o->registry.exact_match.macs);
 		}
-- 
1.7.6.405.gc1be0
