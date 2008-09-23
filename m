From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-next]: net: remove ifalias on empty given alias
Date: Tue, 23 Sep 2008 21:52:08 +0200
Message-ID: <48D948E8.6090804@hartkopp.net>
References: <20080922174346.2ad15d26@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050109040009020009060509"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:27807 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbYIWTwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 15:52:06 -0400
In-Reply-To: <20080922174346.2ad15d26@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050109040009020009060509
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes the potentially allocated ifalias when the (new) 
given alias is empty.

E.g. when setting

echo "" > /sys/class/net/eth0/ifalias

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
---

Hello Stephen,

this patch allows to 'remove' or reset the ifalias by giving an empty alias.
The patch is tested.
Btw. ifalias is a nice idea also for CAN bus people to 'name' a given 
CAN bus.

Thanks & regards,
Oliver



--------------050109040009020009060509
Content-Type: text/x-patch;
 name="empty_ifalias.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="empty_ifalias.patch"

diff --git a/net/core/dev.c b/net/core/dev.c
index e913905..a90737f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -967,6 +967,14 @@ int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 	if (len >= IFALIASZ)
 		return -EINVAL;
 
+	if (!len) {
+		if (dev->ifalias) {
+			kfree(dev->ifalias);
+			dev->ifalias = NULL;
+		}
+		return 0;
+	}
+
 	dev->ifalias = krealloc(dev->ifalias, len+1, GFP_KERNEL);
 	if (!dev->ifalias)
 		return -ENOMEM;

--------------050109040009020009060509--
