From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH 11/13] bnx2x: Forbid LRO on when XEN is enabled
Date: Sun, 18 Apr 2010 17:50:58 +0300
Message-ID: <1271602258.27235.200.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>, dmitry@broadcom.com
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3632 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754910Ab0DROvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 10:51:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LRO cannot be used on virtualized environment, so it is best
to disable it on compile time in XEN kernel.


Author: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a35def6..ab9a9eb 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -52,6 +52,10 @@
 #include <linux/stringify.h>
 
 
+#if defined(CONFIG_XEN)
+#define __NO_TPA__		1
+#endif
+
 #include "bnx2x.h"
 #include "bnx2x_init.h"
 #include "bnx2x_init_ops.h"
-- 
1.6.3.3




