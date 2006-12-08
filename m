From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 03/22] ixgb: Write RA register high word first, increment version
Date: Fri, 08 Dec 2006 15:02:51 -0800
Message-ID: <20061208230250.30109.60518.stgit@gitlost.site>
References: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4355 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761256AbWLHWwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:52:08 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061208230209.30109.49157.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We need to disable the AV bit before flushing the low register.

Signed-off-by: <aaron.k.salter@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_hw.c   |    3 ++-
 drivers/net/ixgb/ixgb_main.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 02089b6..ecbf458 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -399,8 +399,9 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
 	/* Zero out the other 15 receive addresses. */
 	DEBUGOUT("Clearing RAR[1-15]\n");
 	for(i = 1; i < IXGB_RAR_ENTRIES; i++) {
-		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
+		/* Write high reg first to disable the AV bit first */
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
+		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 	}
 
 	return;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 9522d5e..d70accb 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -36,7 +36,7 @@ static char ixgb_driver_string[] = "Inte
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-#define DRV_VERSION		"1.0.117-k2"DRIVERNAPI
+#define DRV_VERSION		"1.0.126-k2"DRIVERNAPI
 char ixgb_driver_version[] = DRV_VERSION;
 static char ixgb_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 



---
Auke Kok <auke-jan.h.kok@intel.com>
