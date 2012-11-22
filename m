From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH 1/1 v2] asix: use ramdom hw addr if the one read is not valid
Date: Thu, 22 Nov 2012 08:35:17 +0100
Message-ID: <1353569717-1260-1-git-send-email-plagnioj@jcrosoft.com>
References: <1353493362-30418-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1353493362-30418-1-git-send-email-plagnioj@jcrosoft.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Cc: linux-usb@vger.kernel.org
Cc: netdev@vger.kernel.org
---
v2:

	introduce asix_set_netdev_dev_addr

Best Regards,
J.
 drivers/net/usb/asix_devices.c |   19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 33ab824..7a6e758 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -64,6 +64,16 @@ static void asix_status(struct usbnet *dev, struct urb *urb)
 	}
 }
 
+static void asix_set_netdev_dev_addr(struct usbnet *dev, u8 *addr)
+{
+	if (is_valid_ether_addr(addr)) {
+		memcpy(dev->net->dev_addr, addr, ETH_ALEN);
+	} else {
+		netdev_info(dev->net, "invalid hw address, using random\n");
+		eth_hw_addr_random(dev->net);
+	}
+}
+
 /* Get the PHY Identifier from the PHYSID1 & PHYSID2 MII registers */
 static u32 asix_get_phyid(struct usbnet *dev)
 {
@@ -225,7 +235,8 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 			   ret);
 		goto out;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+
+	asix_set_netdev_dev_addr(dev, buf);
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
@@ -423,7 +434,8 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		netdev_dbg(dev->net, "Failed to read MAC address: %d\n", ret);
 		return ret;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+
+	asix_set_netdev_dev_addr(dev, buf);
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
@@ -777,7 +789,8 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 		netdev_dbg(dev->net, "Failed to read MAC address: %d\n", ret);
 		return ret;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+
+	asix_set_netdev_dev_addr(dev, buf);
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
-- 
1.7.10.4
