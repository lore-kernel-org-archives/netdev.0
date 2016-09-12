From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 10/15] natsemi: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:41 -0400
Message-ID: <1473689026-6983-11-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:59845
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933000AbcILOEz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 10:04:55 -0400
In-Reply-To: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/natsemi/ns83820.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index eb807b0dc72a..569ade6cf85c 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -134,7 +134,7 @@ static int lnksts = 0;		/* CFG_LNKSTS bit polarity */
 
 /* tunables */
 #define RX_BUF_SIZE	1500	/* 8192 */
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 #define NS83820_VLAN_ACCEL_SUPPORT
 #endif
 
-- 
2.7.4
