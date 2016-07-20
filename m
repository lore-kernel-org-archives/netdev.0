From: zyjzyj2000@gmail.com
Subject: [PATCH 1/1] ixgbevf: replace num with macro
Date: Wed, 20 Jul 2016 12:36:41 +0800
Message-ID: <1468989401-28529-1-git-send-email-zyjzyj2000@gmail.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [123.119.179.77] ([123.119.179.77]:37450 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751304AbcGTEgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 00:36:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

With the original num, when a several bits state is set, it is
possible that the wrong test occurs.

For example,

a state is 0x3, its bits are 11. When testing a state 0x2 whose
bits are 10, it is difficult to confirm that state 0x2 is set or
not.

As such, the MACROs are defined to avoid the above error.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 60fc63b..d37b910 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -436,18 +436,16 @@ struct ixgbevf_adapter {
 	u8 rss_indir_tbl[IXGBEVF_X550_VFRETA_SIZE];
 };
 
-enum ixbgevf_state_t {
-	__IXGBEVF_TESTING,
-	__IXGBEVF_RESETTING,
-	__IXGBEVF_DOWN,
-	__IXGBEVF_DISABLED,
-	__IXGBEVF_REMOVING,
-	__IXGBEVF_SERVICE_SCHED,
-	__IXGBEVF_SERVICE_INITED,
-	__IXGBEVF_RESET_REQUESTED,
-	__IXGBEVF_QUEUE_RESET_REQUESTED,
-	__IXGBEVF_HW_RESETTING,
-};
+#define	__IXGBEVF_TESTING		0x0001
+#define	__IXGBEVF_RESETTING		0x0002
+#define	__IXGBEVF_DOWN			0x0004
+#define	__IXGBEVF_DISABLED		0x0008
+#define	__IXGBEVF_REMOVING		0x0010
+#define	__IXGBEVF_SERVICE_SCHED		0x0020
+#define	__IXGBEVF_SERVICE_INITED	0x0040
+#define	__IXGBEVF_RESET_REQUESTED	0x0080
+#define	__IXGBEVF_QUEUE_RESET_REQUESTED	0x0100
+#define	__IXGBEVF_HW_RESETTING		0x0200
 
 enum ixgbevf_boards {
 	board_82599_vf,
-- 
2.7.4
