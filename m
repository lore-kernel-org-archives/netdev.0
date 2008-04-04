From: Pavel Emelyanov <xemul@openvz.org>
Subject: [RFC][PATCH 2/3] Move net_device->init callback on net_device_ops.
Date: Fri, 04 Apr 2008 18:12:27 +0400
Message-ID: <47F6374B.5000207@openvz.org>
References: <47F63681.1030603@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:57711 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756086AbYDDNsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 09:48:51 -0400
Received: from [10.30.3.76] (swsoft-msk-nat.sw.ru [195.214.232.10])
	(authenticated bits=0)
	by sacred.ru (8.13.8/8.13.8) with ESMTP id m34DmhhD009898
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 4 Apr 2008 17:48:43 +0400
In-Reply-To: <47F63681.1030603@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is how all the other temporary operations will be done.
The return code is still 0 in case init is not set by driver.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/core/dev.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5e7bf79..a01c078 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3701,8 +3701,8 @@ int register_netdevice(struct net_device *dev)
 	dev->iflink = -1;
 
 	/* Init, if this function is available */
-	if (dev->init) {
-		ret = dev->init(dev);
+	if (dev->nd_ops->init) {
+		ret = dev->nd_ops->init(dev);
 		if (ret) {
 			if (ret > 0)
 				ret = -EIO;
@@ -3980,7 +3980,16 @@ static struct net_device_stats *internal_stats(struct net_device *dev)
  * temporary devices operations - to be removed very soon
  */
 
+static int nd_default_init(struct net_device *dev)
+{
+	if (dev->init)
+		return dev->init(dev);
+	else
+		return 0;
+}
+
 static struct net_device_ops nd_default_ops = {
+	.init			= nd_default_init,
 };
 
 /**
-- 
1.5.3.4

