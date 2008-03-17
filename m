From: =?utf-8?q?S=2E=C3=87a=C4=9Flar=20Onur?= <caglar@pardus.org.tr>
Subject: [PATCH] drivers/net/tokenring/3c359.c: Use time_* macros
Date: Mon, 17 Mar 2008 11:36:30 +0200
Message-ID: <1205746593-24820-8-git-send-email-caglar@pardus.org.tr>
References: <>
 <1205746593-24820-1-git-send-email-caglar@pardus.org.tr>
 <1205746593-24820-2-git-send-email-caglar@pardus.org.tr>
 <1205746593-24820-3-git-send-email-caglar@pardus.org.tr>
 <1205746593-24820-4-git-send-email-caglar@pardus.org.tr>
 <1205746593-24820-5-git-send-email-caglar@pardus.org.tr>
 <1205746593-24820-6-git-send-email-caglar@pardus.org.tr>
 <1205746593-24820-7-git-send-email-caglar@pardus.org.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:42594 "EHLO uludag.org.tr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754022AbYCQJh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 05:37:28 -0400
In-Reply-To: <1205746593-24820-7-git-send-email-caglar@pardus.org.tr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions time_before, time_before_eq, time_after, and time_after_e=
q are more robust for comparing jiffies against other values.

So following patch implements usage of the time_after() macro, defined =
at linux/jiffies.h, which deals with wrapping correctly

Cc: netdev@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: S.=C3=87a=C4=9Flar Onur <caglar@pardus.org.tr>
---
 drivers/net/tokenring/3c359.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c35=
9.c
index 44a06f8..88fe955 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -42,6 +42,7 @@
=20
 #define XL_DEBUG 0
=20
+#include <linux/jiffies.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
@@ -408,7 +409,7 @@ static int xl_hw_reset(struct net_device *dev)
 	t=3Djiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) {=20
 		schedule();	=09
-		if(jiffies-t > 40*HZ) {
+		if(time_after(jiffies, t + 40 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL  card not responding to=
 global reset.\n", dev->name);
 			return -ENODEV;
 		}
@@ -519,7 +520,7 @@ static int xl_hw_reset(struct net_device *dev)
 	t=3Djiffies;
 	while ( !(readw(xl_mmio + MMIO_INTSTATUS_AUTO) & INTSTAT_SRB) ) {=20
 		schedule();	=09
-		if(jiffies-t > 15*HZ) {
+		if(time_after(jiffies, t + 15 * HZ)) {
 			printk(KERN_ERR "3COM 3C359 Velocity XL  card not responding.\n");
 			return -ENODEV;=20
 		}
@@ -790,7 +791,7 @@ static int xl_open_hw(struct net_device *dev)
 	t=3Djiffies;
 	while (! (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_SRB)) {=20
 		schedule();	=09
-		if(jiffies-t > 40*HZ) {
+		if(time_after(jiffies, t + 40 * HZ)) {
 			printk(KERN_ERR "3COM 3C359 Velocity XL  card not responding.\n");
 			break ;=20
 		}
@@ -1003,7 +1004,7 @@ static void xl_reset(struct net_device *dev)
=20
 	t=3Djiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) {=20
-		if(jiffies-t > 40*HZ) {
+		if(time_after(jiffies, t + 40 * HZ)) {
 			printk(KERN_ERR "3COM 3C359 Velocity XL  card not responding.\n");
 			break ;=20
 		}
@@ -1270,7 +1271,7 @@ static int xl_close(struct net_device *dev)
 	t=3Djiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) {=20
 		schedule();	=09
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-DNSTALL not responding.=
\n", dev->name);
 			break ;=20
 		}
@@ -1279,7 +1280,7 @@ static int xl_close(struct net_device *dev)
 	t=3Djiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) {=20
 		schedule();	=09
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-DNDISABLE not respondin=
g.\n", dev->name);
 			break ;
 		}
@@ -1288,7 +1289,7 @@ static int xl_close(struct net_device *dev)
 	t=3Djiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) {=20
 		schedule();	=09
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-UPSTALL not responding.=
\n", dev->name);
 			break ;=20
 		}
@@ -1305,7 +1306,7 @@ static int xl_close(struct net_device *dev)
 	t=3Djiffies;
 	while (!(readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_SRB)) {=20
 		schedule();	=09
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-CLOSENIC not responding=
=2E\n", dev->name);
 			break ;=20
 		}
@@ -1334,7 +1335,7 @@ static int xl_close(struct net_device *dev)
 	t=3Djiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) {=20
 		schedule();	=09
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-UPRESET not responding.=
\n", dev->name);
 			break ;=20
 		}
@@ -1343,7 +1344,7 @@ static int xl_close(struct net_device *dev)
 	t=3Djiffies;
 	while (readw(xl_mmio + MMIO_INTSTATUS) & INTSTAT_CMD_IN_PROGRESS) {=20
 		schedule();	=09
-		if(jiffies-t > 10*HZ) {
+		if(time_after(jiffies, t + 10 * HZ)) {
 			printk(KERN_ERR "%s: 3COM 3C359 Velocity XL-DNRESET not responding.=
\n", dev->name);
 			break ;=20
 		}
--=20
1.5.4.3

