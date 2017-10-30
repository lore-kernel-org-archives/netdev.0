From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 6/9] mlxsw: reg: Add ext and tc-cong counter groups
Date: Mon, 30 Oct 2017 09:56:10 +0100
Message-ID: <20171030085613.8697-7-jiri@resnulli.us>
References: <20171030085613.8697-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com,
        ogerlitz@mellanox.com, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:53548 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752682AbdJ3I4V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 04:56:21 -0400
Received: by mail-wm0-f67.google.com with SMTP id r196so14760027wmf.2
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 01:56:20 -0700 (PDT)
In-Reply-To: <20171030085613.8697-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalm@mellanox.com>

This adds the counter group definitions for 2 new counter groups
which are necessary for gaining ECN & wred counters.

Signed-off-by: Yuval Mintz <yuvalm@mellanox.com>
Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 48f051f..d1632c8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3341,8 +3341,10 @@ MLXSW_ITEM32(reg, ppcnt, pnat, 0x00, 14, 2);
 
 enum mlxsw_reg_ppcnt_grp {
 	MLXSW_REG_PPCNT_IEEE_8023_CNT = 0x0,
+	MLXSW_REG_PPCNT_EXT_CNT = 0x5,
 	MLXSW_REG_PPCNT_PRIO_CNT = 0x10,
 	MLXSW_REG_PPCNT_TC_CNT = 0x11,
+	MLXSW_REG_PPCNT_TC_CONG_TC = 0x13,
 };
 
 /* reg_ppcnt_grp
@@ -3358,6 +3360,7 @@ enum mlxsw_reg_ppcnt_grp {
  * 0x10: Per Priority Counters
  * 0x11: Per Traffic Class Counters
  * 0x12: Physical Layer Counters
+ * 0x13: Per Traffic Class Congestion Counters
  * Access: Index
  */
 MLXSW_ITEM32(reg, ppcnt, grp, 0x00, 0, 6);
@@ -3496,6 +3499,14 @@ MLXSW_ITEM64(reg, ppcnt, a_pause_mac_ctrl_frames_received,
 MLXSW_ITEM64(reg, ppcnt, a_pause_mac_ctrl_frames_transmitted,
 	     MLXSW_REG_PPCNT_COUNTERS_OFFSET + 0x90, 0, 64);
 
+/* Ethernet Extended Counter Group Counters */
+
+/* reg_ppcnt_ecn_marked
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, ecn_marked,
+	     MLXSW_REG_PPCNT_COUNTERS_OFFSET + 0x08, 0, 64);
+
 /* Ethernet Per Priority Group Counters */
 
 /* reg_ppcnt_rx_octets
@@ -3571,6 +3582,14 @@ MLXSW_ITEM64(reg, ppcnt, tc_transmit_queue,
 MLXSW_ITEM64(reg, ppcnt, tc_no_buffer_discard_uc,
 	     MLXSW_REG_PPCNT_COUNTERS_OFFSET + 0x08, 0, 64);
 
+/* Ethernet Per Traffic Class Congestion Group Counters */
+
+/* reg_ppcnt_wred_discard
+ * Access: RO
+ */
+MLXSW_ITEM64(reg, ppcnt, wred_discard,
+	     MLXSW_REG_PPCNT_COUNTERS_OFFSET + 0x00, 0, 64);
+
 static inline void mlxsw_reg_ppcnt_pack(char *payload, u8 local_port,
 					enum mlxsw_reg_ppcnt_grp grp,
 					u8 prio_tc)
-- 
2.9.5
