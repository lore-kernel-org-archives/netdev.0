From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 20/20] igb: cleanup "todo" code found in
	igb_ethtool.c
Date: Tue, 27 Oct 2009 18:55:41 -0700
Message-ID: <20091028015540.12470.4985.stgit@localhost.localdomain>
References: <20091028014858.12470.99520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:42806 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756057AbZJ1B7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:59:24 -0400
In-Reply-To: <20091028014858.12470.99520.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch moves some defines into the e1000_regs.h file since this is the
correct place for register defines and not inside of igb_ethtool.c

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_regs.h  |    7 +++++++
 drivers/net/igb/igb_ethtool.c |   11 +----------
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 76c3389..e06c3b7 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -288,10 +288,17 @@ enum {
 #define E1000_MTA      0x05200  /* Multicast Table Array - RW Array */
 #define E1000_RA       0x05400  /* Receive Address - RW Array */
 #define E1000_RA2      0x054E0  /* 2nd half of receive address array - RW Array */
+#define E1000_PSRTYPE(_i)       (0x05480 + ((_i) * 4))
 #define E1000_RAL(_i)  (((_i) <= 15) ? (0x05400 + ((_i) * 8)) : \
                                        (0x054E0 + ((_i - 16) * 8)))
 #define E1000_RAH(_i)  (((_i) <= 15) ? (0x05404 + ((_i) * 8)) : \
                                        (0x054E4 + ((_i - 16) * 8)))
+#define E1000_IP4AT_REG(_i)     (0x05840 + ((_i) * 8))
+#define E1000_IP6AT_REG(_i)     (0x05880 + ((_i) * 4))
+#define E1000_WUPM_REG(_i)      (0x05A00 + ((_i) * 4))
+#define E1000_FFMT_REG(_i)      (0x09000 + ((_i) * 8))
+#define E1000_FFVT_REG(_i)      (0x09800 + ((_i) * 8))
+#define E1000_FFLT_REG(_i)      (0x05F00 + ((_i) * 8))
 #define E1000_VFTA     0x05600  /* VLAN Filter Table Array - RW Array */
 #define E1000_VT_CTL   0x0581C  /* VMDq Control - RW */
 #define E1000_WUC      0x05800  /* Wakeup Control - RW */
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 65c538f..048a615 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -502,19 +502,10 @@ static void igb_get_regs(struct net_device *netdev,
 	regs_buff[119] = adapter->stats.scvpc;
 	regs_buff[120] = adapter->stats.hrmpc;
 
-	/* These should probably be added to e1000_regs.h instead */
-	#define E1000_PSRTYPE_REG(_i) (0x05480 + ((_i) * 4))
-	#define E1000_IP4AT_REG(_i)   (0x05840 + ((_i) * 8))
-	#define E1000_IP6AT_REG(_i)   (0x05880 + ((_i) * 4))
-	#define E1000_WUPM_REG(_i)    (0x05A00 + ((_i) * 4))
-	#define E1000_FFMT_REG(_i)    (0x09000 + ((_i) * 8))
-	#define E1000_FFVT_REG(_i)    (0x09800 + ((_i) * 8))
-	#define E1000_FFLT_REG(_i)    (0x05F00 + ((_i) * 8))
-
 	for (i = 0; i < 4; i++)
 		regs_buff[121 + i] = rd32(E1000_SRRCTL(i));
 	for (i = 0; i < 4; i++)
-		regs_buff[125 + i] = rd32(E1000_PSRTYPE_REG(i));
+		regs_buff[125 + i] = rd32(E1000_PSRTYPE(i));
 	for (i = 0; i < 4; i++)
 		regs_buff[129 + i] = rd32(E1000_RDBAL(i));
 	for (i = 0; i < 4; i++)

