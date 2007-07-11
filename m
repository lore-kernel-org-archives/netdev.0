From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: [PATCH 2/5] net: use numa_node in net_devcice->dev instead of parent
Date: Tue, 10 Jul 2007 17:05:27 -0700
Message-ID: <200707101705.27958.yinghai.lu@sun.com>
References: <200707101641.17672.yinghai.lu@sun.com>
Reply-To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>,
	Greg KH <greg@kroah.com>, rientjes@google.com,
	Christoph Lameter <clameter@sgi.com>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:38494 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763628AbXGKACM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 20:02:12 -0400
In-reply-to: <200707101641.17672.yinghai.lu@sun.com>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 2/5] net: use numa_node in net_devcice->dev instead of parent

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
