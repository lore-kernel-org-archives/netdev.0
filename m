From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH] cxacru: Fix negative dB output
Date: Thu, 23 Apr 2009 18:19:02 +0100
Message-ID: <49F0A306.9010409@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754587AbZDWRTV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Values of dB between -0.99 and -0.01 will be output with the wrong
sign. This converts the negative value to positive and outputs it
with a "-" prefix.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 drivers/usb/atm/cxacru.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/atm/cxacru.c b/drivers/usb/atm/cxacru.c
index 6789089..56802d2 100644
--- a/drivers/usb/atm/cxacru.c
+++ b/drivers/usb/atm/cxacru.c
@@ -227,8 +227,14 @@ static ssize_t cxacru_sysfs_showattr_s8(s8 value, char *buf)
 
 static ssize_t cxacru_sysfs_showattr_dB(s16 value, char *buf)
 {
-	return snprintf(buf, PAGE_SIZE, "%d.%02u\n",
-					value / 100, abs(value) % 100);
+	if (likely(value >= 0)) {
+		return snprintf(buf, PAGE_SIZE, "%u.%02u\n",
+					value / 100, value % 100);
+	} else {
+		value = -value;
+		return snprintf(buf, PAGE_SIZE, "-%u.%02u\n",
+					value / 100, value % 100);
+	}
 }
 
 static ssize_t cxacru_sysfs_showattr_bool(u32 value, char *buf)
-- 
1.6.2.2

-- 
Simon Arlott
