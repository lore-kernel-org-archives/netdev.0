From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax/i2400m: drop support for deprecated major fw interface, add for new minor
Date: Sun,  1 Mar 2009 01:42:48 -0800
Message-ID: <1235900574-15319-2-git-send-email-inaky@linux.intel.com>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:33365 "EHLO
	inaky-mobl3" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753059AbZCAJm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 04:42:57 -0500
In-Reply-To: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware interface version 8.x.x has long been deprecated and is no
longer supported (nor available, as it is a preproduction firmware),
so it can be safely dropped.

Add support for firmware interface v9.2.x (current is 9.1.x). Firmware
version 9.2.x is backwards compatible with 9.1.x; new features are
enabled if switches are pressed to turn them on. Forthcoming commits
to the driver will start pressing those switches when the firmware
interface supports it.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 15d9f51..ac8fb6d 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -942,8 +942,8 @@ error_cmd_failed:
 /* Firmware interface versions we support */
 enum {
 	I2400M_HDIv_MAJOR = 9,
-	I2400M_HDIv_MAJOR_2 = 8,
 	I2400M_HDIv_MINOR = 1,
+	I2400M_HDIv_MINOR_2 = 2,
 };
 
 
@@ -1009,18 +1009,14 @@ int i2400m_firmware_check(struct i2400m *i2400m)
 	minor = le16_to_cpu(l4mv->minor);
 	branch = le16_to_cpu(l4mv->branch);
 	result = -EINVAL;
-	if (major != I2400M_HDIv_MAJOR
-	    && major != I2400M_HDIv_MAJOR_2) {
-		dev_err(dev, "unsupported major fw interface version "
+	if (major != I2400M_HDIv_MAJOR) {
+		dev_err(dev, "unsupported major fw version "
 			"%u.%u.%u\n", major, minor, branch);
 		goto error_bad_major;
 	}
-	if (major == I2400M_HDIv_MAJOR_2)
-		dev_err(dev, "deprecated major fw interface version "
-			"%u.%u.%u\n", major, minor, branch);
 	result = 0;
-	if (minor != I2400M_HDIv_MINOR)
-		dev_warn(dev, "untested minor fw firmware version %u.%u.%u\n",
+	if (minor < I2400M_HDIv_MINOR_2 && minor > I2400M_HDIv_MINOR)
+		dev_warn(dev, "untested minor fw version %u.%u.%u\n",
 			 major, minor, branch);
 error_bad_major:
 	dev_info(dev, "firmware interface version %u.%u.%u\n",
-- 
1.5.6.5

