From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 04/18] e1000: Enble early receive (ERT) on 82573
Date: Wed, 01 Nov 2006 09:51:37 -0800
Message-ID: <20061101175137.2356.92225.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:15888 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946961AbWKARm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:42:59 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Enable early receives on 82573 for jumbo frame performance. Jumbo's
are only supported on 82573L with ASPM disabled.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 1e1198b..194a07d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1934,6 +1934,12 @@ e1000_configure_rx(struct e1000_adapter 
 		E1000_WRITE_REG(hw, RXCSUM, rxcsum);
 	}
 
+	/* enable early receives on 82573, only takes effect if using > 2048
+	 * byte total frame size.  for example only for jumbo frames */
+#define E1000_ERT_2048 0x100
+	if (hw->mac_type == e1000_82573)
+		E1000_WRITE_REG(hw, ERT, E1000_ERT_2048);
+
 	/* Enable Receives */
 	E1000_WRITE_REG(hw, RCTL, rctl);
 }



---
Auke Kok <auke-jan.h.kok@intel.com>
