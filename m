From: "Darren Jenkins\\" <darrenrjenkins@gmail.com>
Subject: [KJ][Patch][update] remove dead code in bcm43xx_sysfs.c
Date: Thu, 07 Sep 2006 20:07:34 +1000
Message-ID: <1157623654.22555.27.camel@localhost.localdomain>
References: <1157614059.22555.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:16409 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751458AbWIGKIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 06:08:10 -0400
Received: by wx-out-0506.google.com with SMTP id s14so191856wxc
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2006 03:08:09 -0700 (PDT)
To: kernel Janitors <kernel-janitors@lists.osdl.org>
In-Reply-To: <1157614059.22555.19.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

G'day people

Coverity CID 1160 & 1161

These are probably fixed in some external tree, but in case they are
not, here is a patch

Compile tested with allyesconfig

Remove some dead cose from bcm43xx_sysfs.c in 2.6.18-rc6

Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>
--- drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c.orig	2006-09-07 15:40:33.000000000 +1000
+++ drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c	2006-09-07 17:35:18.000000000 +1000
@@ -251,7 +251,6 @@ static ssize_t bcm43xx_attr_preamble_sho
 					  char *buf)
 {
 	struct bcm43xx_private *bcm = dev_to_bcm(dev);
-	int err;
 	ssize_t count;
 
 	if (!capable(CAP_NET_ADMIN))
@@ -264,10 +263,9 @@ static ssize_t bcm43xx_attr_preamble_sho
 	else
 		count = snprintf(buf, PAGE_SIZE, "0 (Short Preamble disabled)\n");
 
-	err = 0;
 	bcm43xx_unlock_noirq(bcm);
 
-	return err ? err : count;
+	return count;
 }
 
 static ssize_t bcm43xx_attr_preamble_store(struct device *dev,
@@ -276,7 +274,6 @@ static ssize_t bcm43xx_attr_preamble_sto
 {
 	struct bcm43xx_private *bcm = dev_to_bcm(dev);
 	unsigned long flags;
-	int err;
 	int value;
 
 	if (!capable(CAP_NET_ADMIN))
@@ -289,10 +286,9 @@ static ssize_t bcm43xx_attr_preamble_sto
 
 	bcm->short_preamble = !!value;
 
-	err = 0;
 	bcm43xx_unlock_irqsafe(bcm, flags);
 
-	return err ? err : count;
+	return count;
 }
 
 static DEVICE_ATTR(shortpreamble, 0644,


