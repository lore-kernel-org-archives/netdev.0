From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 19/21] e1000: allow user to disable ich8 lock loss workaround
Date: Wed, 21 Jun 2006 22:20:49 -0700
Message-ID: <20060622052048.25497.45771.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:64008 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932798AbWFVFOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:51 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The workaround for the ich8 lock loss problem is only needed for
a very small amount of systems. This adds an option for the user
to disable the workaround.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_param.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index bd6c040..0ef4131 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -202,6 +202,15 @@ E1000_PARAM(InterruptThrottleRate, "Inte
 
 E1000_PARAM(SmartPowerDownEnable, "Enable PHY smart power down");
 
+/* Enable Kumeran Lock Loss workaround
+ *
+ * Valid Range: 0, 1
+ *
+ * Default Value: 1 (enabled)
+ */
+
+E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
+
 #define AUTONEG_ADV_DEFAULT  0x2F
 #define AUTONEG_ADV_MASK     0x2F
 #define FLOW_CONTROL_DEFAULT FLOW_CONTROL_FULL
@@ -484,6 +493,18 @@ e1000_check_options(struct e1000_adapter
 		e1000_validate_option(&spd, &opt, adapter);
 		adapter->smart_power_down = spd;
 	}
+	{ /* Kumeran Lock Loss Workaround */
+		struct e1000_option opt = {
+			.type = enable_option,
+			.name = "Kumeran Lock Loss Workaround",
+			.err  = "defaulting to Enabled",
+			.def  = OPTION_ENABLED
+		};
+
+			int kmrn_lock_loss = KumeranLockLoss[bd];
+			e1000_validate_option(&kmrn_lock_loss, &opt, adapter);
+			adapter->hw.kmrn_lock_loss_workaround_disabled = !kmrn_lock_loss;
+	}
 
 	switch (adapter->hw.media_type) {
 	case e1000_media_type_fiber:



--
Auke Kok <auke-jan.h.kok@intel.com>
