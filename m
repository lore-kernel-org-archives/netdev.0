From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] sgiseeq: Fix return type of sgiseeq_remove
Date: Wed, 22 Aug 2007 16:03:52 +0100
Message-ID: <20070822150352.GA18889@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:58190 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbXHVPD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 11:03:56 -0400
Received: from localhost.localdomain ([127.0.0.1]:17877 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20022780AbXHVPDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 16:03:54 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver remove method needs to return an int not void.  This was just
never noticed because usually this driver is not being built as a module.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 384b468..0fb74cb 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -726,7 +726,7 @@ err_out:
 	return err;
 }
 
-static void __exit sgiseeq_remove(struct platform_device *pdev)
+static int __exit sgiseeq_remove(struct platform_device *pdev)
 {
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct sgiseeq_private *sp = netdev_priv(dev);
@@ -735,6 +735,8 @@ static void __exit sgiseeq_remove(struct platform_device *pdev)
 	free_page((unsigned long) sp->srings);
 	free_netdev(dev);
 	platform_set_drvdata(pdev, NULL);
+
+	return 0;
 }
 
 static struct platform_driver sgiseeq_driver = {
