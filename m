From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 03/14] fix neterion/vxge
Date: Tue, 19 Jun 2012 18:13:57 +0300
Message-ID: <1340118848-30978-4-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jon Mason" <jdmason@kudzu.us>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3913 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457Ab2FSPQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:23 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 2578eb1..a2c6e3f 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3686,8 +3686,13 @@ static int __devinit vxge_config_vpaths(
 		if (driver_config->g_no_cpus == -1)
 			return 0;
 
-		if (!driver_config->g_no_cpus)
-			driver_config->g_no_cpus = num_online_cpus();
+		if (!driver_config->g_no_cpus) {
+			int ncpu = min_t(int, num_online_cpus(),
+					 DEFAULT_MAX_NUM_RSS_QUEUES);
+			driver_config->g_no_cpus = ncpu;
+		}
+
+
 
 		driver_config->vpath_per_dev = driver_config->g_no_cpus >> 1;
 		if (!driver_config->vpath_per_dev)
-- 
1.7.9.rc2
