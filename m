From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: [PATCH 2/4] net: use numa_node in net_devcice->dev instead of parent
Date: Tue, 03 Jul 2007 17:30:51 -0700
Message-ID: <200707031730.51677.yinghai.lu@sun.com>
References: <200706291330.37070.yinghai.lu@sun.com> <468ABF92.5030800@sun.com>
 <20070703143407.7e4232f8@freepuppy.localdomain.hemminger.net>
Reply-To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760083AbXGDAeF@vger.kernel.org>
In-reply-to: <20070703143407.7e4232f8@freepuppy.localdomain.hemminger.net>
Content-disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 2/4] net: use numa_node in net_devcice->dev instead of parent

Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 27cfe5f..005cc1c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -217,7 +217,7 @@ nodata:
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		unsigned int length, gfp_t gfp_mask)
 {
-	int node = dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
+	int node = dev_to_node(&dev->dev);
 	struct sk_buff *skb;
 
 	skb = __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
