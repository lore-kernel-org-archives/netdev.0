From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Patchlet 2.6 iucv
Date: Mon, 2 Feb 2004 20:12:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040202201203.4c8b2053.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: schwidefsky@de.ibm.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, Martin,

it seems that someone misused container_of. Spotted by Al Viro.
Please pass to whoever is responsible for IUCV.

-- Pete

--- linux-2.6.1/drivers/s390/net/netiucv.c	2003-10-01 15:17:54.000000000 -0700
+++ linux-2.6.1-s390/drivers/s390/net/netiucv.c	2004-02-02 19:59:11.000000000 -0800
@@ -1258,8 +1258,7 @@
 buffer_write (struct device *dev, const char *buf, size_t count)
 {
 	struct netiucv_priv *priv = dev->driver_data;
-	struct net_device *ndev =
-		container_of((void *)priv, struct net_device, priv);
+	struct net_device *ndev = priv->conn->netdev;
 	char         *e;
 	int          bs1;
 	char         tmp[CTRL_BUFSIZE];
