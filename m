From: Barry Grussling <barry@grussling.com>
Subject: [PATCH 2/4] DSA: Convert msleep calls to usleep_range calls
Date: Wed,  2 Jan 2013 17:54:56 -0800
Message-ID: <1357178098-4057-3-git-send-email-barry@grussling.com>
References: <1357178098-4057-1-git-send-email-barry@grussling.com>
To: barry@grussling.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:41703 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab3ACBze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 20:55:34 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so6700212dak.19
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 17:55:34 -0800 (PST)
In-Reply-To: <1357178098-4057-1-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert DSA msleep calls to usleep_range calls as reported by
checkpatch.pl.

Values of sleep duration were verified on Marvell hardware
platform and appear to work.  Values chosen are not special
and no strong "vetting" has gone into them other than verifying
correct operation on available hardware.


Signed-off-by: Barry Grussling <barry@grussling.com>
---
 drivers/net/dsa/mv88e6060.c       |    7 ++++---
 drivers/net/dsa/mv88e6123_61_65.c |    7 ++++---
 drivers/net/dsa/mv88e6131.c       |    7 ++++---
 drivers/net/dsa/mv88e6xxx.c       |    5 +++--
 4 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 16ec763..fa6bc7d 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -8,6 +8,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/delay.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -76,20 +77,20 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
 
 	/* Wait for transmit queues to drain.
 	 */
-	msleep(2);
+	usleep_range(2000, 4000);
 
 	/* Reset the switch.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x0a, 0xa130);
 
-	/* Wait up to one second for reset to complete.
+	/* Wait up to two seconds for reset to complete.
 	 */
 	for (i = 0; i < 1000; i++) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
 		if ((ret & 0x8000) == 0x0000)
 			break;
 
-		msleep(1);
+		usleep_range(1000, 2000);
 	}
 	if (i == 1000)
 		return -ETIMEDOUT;
diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index f964bfb..0ead9b4 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -8,6 +8,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/delay.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -60,20 +61,20 @@ static int mv88e6123_61_65_switch_reset(struct dsa_switch *ds)
 
 	/* Wait for transmit queues to drain.
 	 */
-	msleep(2);
+	usleep_range(2000, 4000);
 
 	/* Reset the switch.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
 
-	/* Wait up to one second for reset to complete.
+	/* Wait up to two seconds for reset to complete.
 	 */
 	for (i = 0; i < 1000; i++) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
 		if ((ret & 0xc800) == 0xc800)
 			break;
 
-		msleep(1);
+		usleep_range(1000, 2000);
 	}
 	if (i == 1000)
 		return -ETIMEDOUT;
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 7a7bcc2..7872507 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -8,6 +8,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/delay.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -53,20 +54,20 @@ static int mv88e6131_switch_reset(struct dsa_switch *ds)
 
 	/* Wait for transmit queues to drain.
 	 */
-	msleep(2);
+	usleep_range(2000, 4000);
 
 	/* Reset the switch.
 	 */
 	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
 
-	/* Wait up to one second for reset to complete.
+	/* Wait up to two seconds for reset to complete.
 	 */
 	for (i = 0; i < 1000; i++) {
 		ret = REG_READ(REG_GLOBAL, 0x00);
 		if ((ret & 0xc800) == 0xc800)
 			break;
 
-		msleep(1);
+		usleep_range(1000, 2000);
 	}
 	if (i == 1000)
 		return -ETIMEDOUT;
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index eaa341a..a2f9e9b6 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -8,6 +8,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/delay.h>
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -215,7 +216,7 @@ static int mv88e6xxx_ppu_disable(struct dsa_switch *ds)
 
 	for (i = 0; i < 1000; i++) {
 	        ret = REG_READ(REG_GLOBAL, 0x00);
-	        msleep(1);
+		usleep_range(1000, 2000);
 	        if ((ret & 0xc000) != 0xc000)
 	                return 0;
 	}
@@ -233,7 +234,7 @@ static int mv88e6xxx_ppu_enable(struct dsa_switch *ds)
 
 	for (i = 0; i < 1000; i++) {
 	        ret = REG_READ(REG_GLOBAL, 0x00);
-	        msleep(1);
+		usleep_range(1000, 2000);
 	        if ((ret & 0xc000) == 0xc000)
 	                return 0;
 	}
-- 
1.7.9.5
