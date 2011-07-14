From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/6] cnic: Replace get_random_bytes() with
 random32()
Date: Wed, 13 Jul 2011 20:24:17 -0700
Message-ID: <1310613862-27497-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2708 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750862Ab1GNEQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 00:16:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested by Stephen Hemminger <shemminger@vyatta.com>

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/cnic.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 5533b15..23d6108 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -28,6 +28,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/prefetch.h>
+#include <linux/random.h>
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #define BCM_VLAN 1
 #endif
@@ -3830,7 +3831,7 @@ static int cnic_cm_alloc_mem(struct cnic_dev *dev)
 	if (!cp->csk_tbl)
 		return -ENOMEM;
 
-	get_random_bytes(&port_id, sizeof(port_id));
+	port_id = random32();
 	port_id %= CNIC_LOCAL_PORT_RANGE;
 	if (cnic_init_id_tbl(&cp->csk_port_tbl, CNIC_LOCAL_PORT_RANGE,
 			     CNIC_LOCAL_PORT_MIN, port_id)) {
@@ -3890,7 +3891,7 @@ static int cnic_cm_init_bnx2_hw(struct cnic_dev *dev)
 {
 	u32 seed;
 
-	get_random_bytes(&seed, 4);
+	seed = random32();
 	cnic_ctx_wr(dev, 45, 0, seed);
 	return 0;
 }
-- 
1.6.4.GIT


