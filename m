From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 10/13] bnx2x: Set default value of num_queues to 1 on
 32-bit platforms
Date: Sun, 18 Apr 2010 17:50:24 +0300
Message-ID: <1271602224.27235.199.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>, dmitry@broadcom.com
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4833 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755589Ab0DROud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 10:50:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default was changed to save memory on 32bits systems.

Author: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2eb9a3b..a35def6 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -91,10 +91,17 @@ module_param(multi_mode, int, 0);
 MODULE_PARM_DESC(multi_mode, " Multi queue mode "
 			     "(0 Disable; 1 Enable (default))");
 
+#ifdef CONFIG_64BIT
 static int num_queues;
 module_param(num_queues, int, 0);
 MODULE_PARM_DESC(num_queues, " Number of queues for multi_mode=1"
 				" (default is as a number of CPUs)");
+#else
+static int num_queues = 1;
+module_param(num_queues, int, 0);
+MODULE_PARM_DESC(num_queues, " Number of queues for multi_mode=1"
+				" (default 1)");
+#endif
 
 static int disable_tpa;
 module_param(disable_tpa, int, 0);
-- 
1.6.3.3




