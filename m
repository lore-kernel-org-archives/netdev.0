From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/9] tg3: Fix 57765 A0 bootcode race condition
Date: Fri, 12 Feb 2010 16:47:08 -0800
Message-ID: <1266022033-3546-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1322 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757221Ab0BMArk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 19:47:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On A0 revision of 57765 asic rev devices, the bootcode will perform some
hardware operations, after the magic signature is presented, that will
collide with setup operations performed by the driver.  The best way to
avoid the contention is to have the driver delay an additional 10
milliseconds.  B0 revisions of the chip will make this workaround
unnecessary.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    7 +++++++
 drivers/net/tg3.h |    1 +
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e6ee291..d1452d3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6721,6 +6721,13 @@ static int tg3_poll_fw(struct tg3 *tp)
 		       tp->dev->name);
 	}
 
+	if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0) {
+		/* The 57765 A0 needs a little more
+		 * time to do some important work.
+		 */
+		mdelay(10);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index cc8bf7d..46db4ad 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -110,6 +110,7 @@
 #define  CHIPREV_ID_57780_A0		 0x57780000
 #define  CHIPREV_ID_57780_A1		 0x57780001
 #define  CHIPREV_ID_5717_A0		 0x05717000
+#define  CHIPREV_ID_57765_A0		 0x57785000
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
-- 
1.6.4.4


