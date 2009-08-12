From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 21/36] bnx2x: Move printing of version from probe to
 the init
Date: Wed, 12 Aug 2009 21:23:37 +0300
Message-ID: <1250101417.27379.173.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Benjamin Li" <benli@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753361AbZHLSYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move printing of version from probe to the init function
Rather then checking if this is the first module probe call to print
the version of the driver only once, the statement is moved to the init
function of the module where init is only called once

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5042109..347036f 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11871,15 +11871,11 @@ request_firmware_exit:
 static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
-	static int version_printed;
 	struct net_device *dev = NULL;
 	struct bnx2x *bp;
 	int pcie_width, pcie_speed;
 	int rc;
 
-	if (version_printed++ == 0)
-		printk(KERN_INFO "%s", version);
-
 	/* dev zeroed in init_etherdev */
 	dev = alloc_etherdev_mq(sizeof(*bp), MAX_CONTEXT);
 	if (!dev) {
@@ -12217,6 +12213,8 @@ static int __init bnx2x_init(void)
 {
 	int ret;
 
+	printk(KERN_INFO "%s", version);
+
 	bnx2x_wq = create_singlethread_workqueue("bnx2x");
 	if (bnx2x_wq == NULL) {
 		printk(KERN_ERR PFX "Cannot create workqueue\n");
-- 
1.5.4.3




