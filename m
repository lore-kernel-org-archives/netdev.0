From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Nicer WARN_ON in netstat_show
Date: Wed, 28 Nov 2007 13:11:24 +0300
Message-ID: <474D3ECC.8030703@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53440 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756309AbXK1KLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 05:11:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The

	if (statement)
		WARN_ON(1);

looks much better as

	WARN_ON(statement);

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 61ead1d..e41f4b9 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -247,9 +247,8 @@ static ssize_t netstat_show(const struct device *d,
 	struct net_device_stats *stats;
 	ssize_t ret = -EINVAL;
 
-	if (offset > sizeof(struct net_device_stats) ||
-	    offset % sizeof(unsigned long) != 0)
-		WARN_ON(1);
+	WARN_ON(offset > sizeof(struct net_device_stats) ||
+			offset % sizeof(unsigned long) != 0);
 
 	read_lock(&dev_base_lock);
 	if (dev_isalive(dev) && dev->get_stats &&
