From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH]remove dead code in bcm43xx_sysfs.c  (wireless-2.6)
Date: Thu, 07 Sep 2006 11:17:05 -0500
Message-ID: <45004601.8090206@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, Stefano Brivio <st3@riseup.net>,
	netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	darrenrjenkins@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:14794 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932257AbWIGQRG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 12:17:06 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John,

Please queue this patch to remove dead code from bcm43xx-softmac in wireless-2.6. It was submitted
by Darren Jenkins based on a Coverity code checker report. I had to revise the patch for the 2.6.18 
locking model, and have tested it.

Thanks,

Larry

===============

Coverity CID 1160 & 1161
Remove some dead code from bcm43xx_sysfs.c in 2.6.18-rc6

Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

=============

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_sysfs.c
@@ -176,7 +176,6 @@ static ssize_t bcm43xx_attr_interfmode_s
  					    char *buf)
  {
  	struct bcm43xx_private *bcm = dev_to_bcm(dev);
-	int err;
  	ssize_t count = 0;

  	if (!capable(CAP_NET_ADMIN))
@@ -197,11 +196,10 @@ static ssize_t bcm43xx_attr_interfmode_s
  	default:
  		assert(0);
  	}
-	err = 0;

  	mutex_unlock(&bcm->mutex);

-	return err ? err : count;
+	return count;

  }

@@ -259,7 +257,6 @@ static ssize_t bcm43xx_attr_preamble_sho
  					  char *buf)
  {
  	struct bcm43xx_private *bcm = dev_to_bcm(dev);
-	int err;
  	ssize_t count;

  	if (!capable(CAP_NET_ADMIN))
@@ -272,10 +269,9 @@ static ssize_t bcm43xx_attr_preamble_sho
  	else
  		count = snprintf(buf, PAGE_SIZE, "0 (Short Preamble disabled)\n");

-	err = 0;
  	mutex_unlock(&bcm->mutex);

-	return err ? err : count;
+	return count;
  }

  static ssize_t bcm43xx_attr_preamble_store(struct device *dev,
@@ -284,7 +280,6 @@ static ssize_t bcm43xx_attr_preamble_sto
  {
  	struct bcm43xx_private *bcm = dev_to_bcm(dev);
  	unsigned long flags;
-	int err;
  	int value;

  	if (!capable(CAP_NET_ADMIN))
@@ -298,11 +293,10 @@ static ssize_t bcm43xx_attr_preamble_sto

  	bcm->short_preamble = !!value;

-	err = 0;
  	spin_unlock_irqrestore(&bcm->irq_lock, flags);
  	mutex_unlock(&bcm->mutex);

-	return err ? err : count;
+	return count;
  }

  static DEVICE_ATTR(shortpreamble, 0644,


---------


