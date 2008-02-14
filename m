From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] sky2: don't request unused i/o region
Date: Wed, 13 Feb 2008 19:02:37 -0800
Message-ID: <20080213190237.7cd49d60@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46922 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753849AbYBNDC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 22:02:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sky2 driver only uses the PCI memory region (0) not the 
available I/O region.  Some users want to use lots of boards, and the
I/O space gets exhausted.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2008-02-13 18:58:21.000000000 -0800
+++ b/drivers/net/sky2.c	2008-02-13 18:58:55.000000000 -0800
@@ -4135,9 +4135,9 @@ static int __devinit sky2_probe(struct p
 		goto err_out;
 	}
 
-	err = pci_request_regions(pdev, DRV_NAME);
+	err = pci_request_region(pdev, 0, DRV_NAME);
 	if (err) {
-		dev_err(&pdev->dev, "cannot obtain PCI resources\n");
+		dev_err(&pdev->dev, "cannot obtain PCI resource\n");
 		goto err_out_disable;
 	}
 
