From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 1/2] netdev: octeon_mgmt: Fix section mismatch errors.
Date: Thu, 24 Jun 2010 12:14:47 -0700
Message-ID: <1277406888-26309-2-git-send-email-ddaney@caviumnetworks.com>
References: <1277406888-26309-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:16160 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211Ab0FXTO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 15:14:59 -0400
In-Reply-To: <1277406888-26309-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We started getting:

WARNING: drivers/net/built-in.o(.data+0x10f0): Section mismatch in
reference from the variable octeon_mgmt_driver to the function
.init.text:octeon_mgmt_probe()

This fixes it.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/octeon/octeon_mgmt.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 000e792..f4a0f08 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -1067,7 +1067,7 @@ static const struct net_device_ops octeon_mgmt_ops = {
 #endif
 };
 
-static int __init octeon_mgmt_probe(struct platform_device *pdev)
+static int __devinit octeon_mgmt_probe(struct platform_device *pdev)
 {
 	struct resource *res_irq;
 	struct net_device *netdev;
@@ -1124,7 +1124,7 @@ err:
 	return -ENOENT;
 }
 
-static int __exit octeon_mgmt_remove(struct platform_device *pdev)
+static int __devexit octeon_mgmt_remove(struct platform_device *pdev)
 {
 	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
 
@@ -1139,7 +1139,7 @@ static struct platform_driver octeon_mgmt_driver = {
 		.owner		= THIS_MODULE,
 	},
 	.probe		= octeon_mgmt_probe,
-	.remove		= __exit_p(octeon_mgmt_remove),
+	.remove		= __devexit_p(octeon_mgmt_remove),
 };
 
 extern void octeon_mdiobus_force_mod_depencency(void);
-- 
1.6.6.1

