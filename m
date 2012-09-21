From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] mISDN: suppress compiler warning
Date: Fri, 21 Sep 2012 12:25:24 +0200
Message-ID: <1348223124.1581.15.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building the hfcpci driver triggers this GCC warning:
    drivers/isdn/hardware/mISDN/hfcpci.c:2298:2: warning: ignoring return value of 'driver_for_each_device', declared with attribute warn_unused_result [-Wunused-result]

That return value is apparently ignored because _hfcpci_softirq() will
always return 0. Suppress this warning in the way a few other drivers do
that too.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
0) I noticed this warning while building v3.6-rc6 on current Fedora 17,
using Fedora's default config.

1) Compile tested only.

 drivers/isdn/hardware/mISDN/hfcpci.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 81363ff..a547c8c 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2295,8 +2295,11 @@ _hfcpci_softirq(struct device *dev, void *arg)
 static void
 hfcpci_softirq(void *arg)
 {
-	(void) driver_for_each_device(&hfc_driver.driver, NULL, arg,
+	int ret;
+
+	ret = driver_for_each_device(&hfc_driver.driver, NULL, arg,
 				      _hfcpci_softirq);
+	(void)ret;	/* suppress compiler warning */
 
 	/* if next event would be in the past ... */
 	if ((s32)(hfc_jiffies + tics - jiffies) <= 0)
-- 
1.7.11.4
