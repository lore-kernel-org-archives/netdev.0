From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [Ubuntu PATCH] forcedeth: Let the driver work when no PHY is found
Date: Wed, 14 Jun 2006 16:23:05 -0700
Message-ID: <44909A59.7020801@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm <akpm@osdl.org>, manfred@colorfullife.com,
	jgarzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:15935 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S964843AbWFNWXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 18:23:23 -0400
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Collins <bcollins@ubuntu.com>

[UBUNTU:forcedeth] Let the driver work when no PHY is found

This matches breezy behavior.

Reference: https://launchpad.net/products/launchpad/+bug/45257
http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=38c1aaedc1f907e138698e54ceadeb9ae560b0d7

Signed-off-by: Ben Collins <bcollins@ubuntu.com>
---

--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2582,14 +2582,13 @@ static int __devinit nv_probe(struct pci
 		np->phy_oui = id1 | id2;
 		break;
 	}
-	if (i == 33) {
+
+	/* Let the damn card work if it can */
+	if (i == 33)
 		printk(KERN_INFO "%s: open: Could not find a valid PHY.\n",
 		       pci_name(pci_dev));
-		goto out_freering;
-	}
-	
-	/* reset it */
-	phy_init(dev);
+	else
+		phy_init(dev);
 
 	/* set default link speed settings */
 	np->linkspeed = NVREG_LINKSPEED_FORCE|NVREG_LINKSPEED_10;


