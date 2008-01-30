From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] olympic_open() must be __devinit
Date: Wed, 30 Jan 2008 22:02:07 +0200
Message-ID: <20080130200207.GJ29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: p2@ace.ulyssis.student.kuleuven.ac.be, mikep@linuxtr.net,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:51702 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756100AbYA3UBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:01:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following section mismatch:

<--  snip  -->

...
WARNING: drivers/net/built-in.o(.text+0x155573): Section mismatch in reference from the function olympic_open() to the function .devinit.text:olympic_init()
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
fd1e6e0bb5b17dc85cd24d6263e8751e816f59e6 
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index e7b4adc..433c994 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -434,7 +434,7 @@ static int __devinit olympic_init(struct net_device *dev)
 
 }
 
-static int olympic_open(struct net_device *dev) 
+static int __devinit olympic_open(struct net_device *dev) 
 {
 	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio,*init_srb;


