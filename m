From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 10/11] ibm_newemac: Call dev_set_drvdata() before tah_reset()
Date: Fri, 30 Nov 2007 16:40:34 +1100
Message-ID: <20071130054137.27959DDEE4@ozlabs.org>
References: <1196401223.5661.297518056501.qpush@grosgo>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48514 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242AbXK3Fli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 00:41:38 -0500
In-Reply-To: <1196401223.5661.297518056501.qpush@grosgo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valentine Barshak <vbarshak@ru.mvista.com>

The patch moves dev_set_drvdata(&ofdev->dev, dev) up before tah_reset(ofdev)
is called to avoid a NULL pointer dereference, since tah_reset uses drvdata.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/tah.c linux-2.6/drivers/net/ibm_newemac/tah.c
--- linux-2.6.orig/drivers/net/ibm_newemac/tah.c	2007-11-23 21:27:57.000000000 +0300
+++ linux-2.6/drivers/net/ibm_newemac/tah.c	2007-11-23 21:35:12.000000000 +0300
@@ -116,13 +116,14 @@ static int __devinit tah_probe(struct of
 		goto err_free;
 	}
 
+	dev_set_drvdata(&ofdev->dev, dev);
+
 	/* Initialize TAH and enable IPv4 checksum verification, no TSO yet */
 	tah_reset(ofdev);
 
 	printk(KERN_INFO
 	       "TAH %s initialized\n", ofdev->node->full_name);
 	wmb();
-	dev_set_drvdata(&ofdev->dev, dev);
 
 	return 0;
 

