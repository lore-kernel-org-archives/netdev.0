From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/5] cnic: Fix bogus iSCSI MAC address
Date: Wed, 2 Dec 2009 17:15:37 -0800
Message-ID: <1259802939-4742-3-git-send-email-mchan@broadcom.com>
References: <1259802939-4742-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3826 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752929AbZLCBIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 20:08:30 -0500
In-Reply-To: <1259802939-4742-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix code to read the proper iSCSI MAC address for bnx2x devices.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index fb1cadb..bb6ce8d 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3997,15 +3997,19 @@ static void cnic_get_bnx2x_iscsi_info(struct cnic_dev *dev)
 	if (base < 0xa0000 || base >= 0xc0000)
 		return;
 
-	val = BNX2X_SHMEM_ADDR(base,
+	addr = BNX2X_SHMEM_ADDR(base,
 		dev_info.port_hw_config[port].iscsi_mac_upper);
 
+	val = CNIC_RD(dev, addr);
+
 	dev->mac_addr[0] = (u8) (val >> 8);
 	dev->mac_addr[1] = (u8) val;
 
-	val = BNX2X_SHMEM_ADDR(base,
+	addr = BNX2X_SHMEM_ADDR(base,
 		dev_info.port_hw_config[port].iscsi_mac_lower);
 
+	val = CNIC_RD(dev, addr);
+
 	dev->mac_addr[2] = (u8) (val >> 24);
 	dev->mac_addr[3] = (u8) (val >> 16);
 	dev->mac_addr[4] = (u8) (val >> 8);
-- 
1.6.4.GIT


