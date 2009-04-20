From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/8] tg3: Prevent send BD corruption
Date: Mon, 20 Apr 2009 09:57:41 -0700
Message-ID: <1240247957.7018@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1567 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752936AbZDTRTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 13:19:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On rare occasions, send BD corruptions can occur.  This patch
fixes the problem by increasing the L1 entry threshold to 4
milliseconds.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    7 +++++++
 drivers/net/tg3.h |    2 ++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9b04954..ed7a86d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6717,6 +6717,13 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		tw32(TG3_CPMU_HST_ACC, val);
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780) {
+		val = tr32(PCIE_PWR_MGMT_THRESH) & ~PCIE_PWR_MGMT_L1_THRESH_MSK;
+		val |= PCIE_PWR_MGMT_EXT_ASPM_TMR_EN |
+		       PCIE_PWR_MGMT_L1_THRESH_4MS;
+		tw32(PCIE_PWR_MGMT_THRESH, val);
+	}
+
 	/* This works around an issue with Athlon chipsets on
 	 * B3 tigon3 silicon.  This bit has no effect on any
 	 * other revision.  But do not set this on PCI Express
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index afbabf2..f1016cb 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1697,6 +1697,8 @@
 
 #define PCIE_PWR_MGMT_THRESH		0x00007d28
 #define PCIE_PWR_MGMT_L1_THRESH_MSK	 0x0000ff00
+#define PCIE_PWR_MGMT_L1_THRESH_4MS	 0x0000ff00
+#define PCIE_PWR_MGMT_EXT_ASPM_TMR_EN	 0x01000000
 
 
 /* OTP bit definitions */
-- 
1.6.0.6


