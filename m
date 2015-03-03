From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 03/14] net: usb: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:48 -0800
Message-ID: <0655eb70838b934f6cc6a99f8ae615845ec1892a.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Oliver Neukum <oliver@neukum.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/catc.c     | 4 ++--
 drivers/net/usb/cdc_mbim.c | 2 +-
 drivers/net/usb/lg-vl600.c | 2 +-
 drivers/net/usb/qmi_wwan.c | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 8cfc3bb..4e2b26a 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -641,7 +641,7 @@ static void catc_set_multicast_list(struct net_device *netdev)
 	u8 broadcast[ETH_ALEN];
 	u8 rx = RxEnable | RxPolarity | RxMultiCast;
 
-	memset(broadcast, 0xff, ETH_ALEN);
+	eth_broadcast_addr(broadcast);
 	memset(catc->multicast, 0, 64);
 
 	catc_multicast(broadcast, catc->multicast);
@@ -880,7 +880,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 		
 		dev_dbg(dev, "Filling the multicast list.\n");
 	  
-		memset(broadcast, 0xff, ETH_ALEN);
+		eth_broadcast_addr(broadcast);
 		catc_multicast(broadcast, catc->multicast);
 		catc_multicast(netdev->dev_addr, catc->multicast);
 		catc_write_mem(catc, 0xfa80, catc->multicast, 64);
diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 96fc8a5..e4b7a47 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -394,7 +394,7 @@ static struct sk_buff *cdc_mbim_process_dgram(struct usbnet *dev, u8 *buf, size_
 	skb_put(skb, ETH_HLEN);
 	skb_reset_mac_header(skb);
 	eth_hdr(skb)->h_proto = proto;
-	memset(eth_hdr(skb)->h_source, 0, ETH_ALEN);
+	eth_zero_addr(eth_hdr(skb)->h_source);
 	memcpy(eth_hdr(skb)->h_dest, dev->net->dev_addr, ETH_ALEN);
 
 	/* add datagram */
diff --git a/drivers/net/usb/lg-vl600.c b/drivers/net/usb/lg-vl600.c
index 8f37efd..5714107 100644
--- a/drivers/net/usb/lg-vl600.c
+++ b/drivers/net/usb/lg-vl600.c
@@ -201,7 +201,7 @@ static int vl600_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 					&buf->data[sizeof(*ethhdr) + 0x12],
 					ETH_ALEN);
 		} else {
-			memset(ethhdr->h_source, 0, ETH_ALEN);
+			eth_zero_addr(ethhdr->h_source);
 			memcpy(ethhdr->h_dest, dev->net->dev_addr, ETH_ALEN);
 
 			/* Inbound IPv6 packets have an IPv4 ethertype (0x800)
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 602dc66..f603f36 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -108,7 +108,7 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	skb_push(skb, ETH_HLEN);
 	skb_reset_mac_header(skb);
 	eth_hdr(skb)->h_proto = proto;
-	memset(eth_hdr(skb)->h_source, 0, ETH_ALEN);
+	eth_zero_addr(eth_hdr(skb)->h_source);
 fix_dest:
 	memcpy(eth_hdr(skb)->h_dest, dev->net->dev_addr, ETH_ALEN);
 	return 1;
-- 
2.1.2
