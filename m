From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Subject: [PATCH] ptp: use memdup_user().
Date: Fri, 20 May 2016 17:51:02 +0530
Message-ID: <1463746862-23815-1-git-send-email-falakreyaz@gmail.com>
Cc: netdev@vger.kernel.org (open list:PTP HARDWARE CLOCK SUPPORT),
	linux-kernel@vger.kernel.org (open list)
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use memdup_user to duplicate a memory region from user-space to
kernel-space, instead of open coding using kmalloc & copy_from_user.

Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
---
 drivers/ptp/ptp_chardev.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index 579fd65..0b1ac6b 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -208,14 +208,9 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		break;
 
 	case PTP_SYS_OFFSET:
-		sysoff = kmalloc(sizeof(*sysoff), GFP_KERNEL);
-		if (!sysoff) {
-			err = -ENOMEM;
-			break;
-		}
-		if (copy_from_user(sysoff, (void __user *)arg,
-				   sizeof(*sysoff))) {
-			err = -EFAULT;
+		sysoff = memdup_user((void __user *)arg, sizeof(*sysoff));
+		if (IS_ERR(sysoff)) {
+			err = PTR_ERR(sysoff);
 			break;
 		}
 		if (sysoff->n_samples > PTP_MAX_SAMPLES) {
-- 
1.9.1
