From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] 2.6.5-rc1-bk2 loopback.c
Date: Wed, 17 Mar 2004 17:05:22 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403180105.i2I15Mt04579@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply this fix to backout an erroneous change in loopback.c
The statistics structure is allocated separately from the
loopback_dev structure, and the current code overwrites something
other than the statistics.  In my case the scsi_cmd_pool structure.


--- linux-2.6.5-rc1-bk2/drivers/net/orig.loopback.c	Wed Mar 17 08:52:52 2004
+++ linux-2.6.5-rc1-bk2/drivers/net/loopback.c	Wed Mar 17 16:46:40 2004
@@ -123,7 +123,7 @@
  */
 static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = netdev_priv(dev);
+	struct net_device_stats *stats = dev->priv;
 
 	skb_orphan(skb);
 

-- 
Don Fry
brazilnut@us.ibm.com
