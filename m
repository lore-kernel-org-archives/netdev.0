From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/wimax/i2400m/driver.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 10:00:57 -0700
Message-ID: <201001051000.57496.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755176Ab0AEREU@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

Repost due to merge issues.

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 96a615f..6cead32 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -301,24 +301,15 @@ int i2400m_check_mac_addr(struct i2400m *i2400m)
 	/* Extract MAC addresss */
 	ddi = (void *) skb->data;
 	BUILD_BUG_ON(ETH_ALEN != sizeof(ddi->mac_address));
-	d_printf(2, dev, "GET DEVICE INFO: mac addr "
-		 "%02x:%02x:%02x:%02x:%02x:%02x\n",
-		 ddi->mac_address[0], ddi->mac_address[1],
-		 ddi->mac_address[2], ddi->mac_address[3],
-		 ddi->mac_address[4], ddi->mac_address[5]);
+	d_printf(2, dev, "GET DEVICE INFO: mac addr %pM\n",
+		 ddi->mac_address);
 	if (!memcmp(net_dev->perm_addr, ddi->mac_address,
 		   sizeof(ddi->mac_address)))
 		goto ok;
 	dev_warn(dev, "warning: device reports a different MAC address "
 		 "to that of boot mode's\n");
-	dev_warn(dev, "device reports     %02x:%02x:%02x:%02x:%02x:%02x\n",
-		 ddi->mac_address[0], ddi->mac_address[1],
-		 ddi->mac_address[2], ddi->mac_address[3],
-		 ddi->mac_address[4], ddi->mac_address[5]);
-	dev_warn(dev, "boot mode reported %02x:%02x:%02x:%02x:%02x:%02x\n",
-		 net_dev->perm_addr[0], net_dev->perm_addr[1],
-		 net_dev->perm_addr[2], net_dev->perm_addr[3],
-		 net_dev->perm_addr[4], net_dev->perm_addr[5]);
+	dev_warn(dev, "device reports     %pM\n", ddi->mac_address);
+	dev_warn(dev, "boot mode reported %pM\n", net_dev->perm_addr);
 	if (!memcmp(zeromac, ddi->mac_address, sizeof(zeromac)))
 		dev_err(dev, "device reports an invalid MAC address, "
 			"not updating\n");
