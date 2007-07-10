From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: [PATCH 5/5] dma: use dev_to_node to get node for device in
 dma_alloc_pages
Date: Tue, 10 Jul 2007 16:53:09 -0700
Message-ID: <200707101653.09797.yinghai.lu@sun.com>
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
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:38437 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763309AbXGKABA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 20:01:00 -0400
In-reply-to: <200707101641.17672.yinghai.lu@sun.com>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 5/5] dma: use dev_to_node to get node for device in dma_alloc_pages

Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>

diff --git a/arch/x86_64/kernel/pci-dma.c b/arch/x86_64/kernel/pci-dma.c
index 9f80aad..6dbf1c9 100644
--- a/arch/x86_64/kernel/pci-dma.c
+++ b/arch/x86_64/kernel/pci-dma.c
@@ -52,11 +52,9 @@ dma_alloc_pages(struct device *dev, gfp_t gfp, unsigned order)
 {
 	struct page *page;
 	int node;
-#ifdef CONFIG_PCI
-	if (dev->bus == &pci_bus_type)
-		node = pcibus_to_node(to_pci_dev(dev)->bus);
-	else
-#endif
+
+	node = dev_to_node(dev);
+	if (node == -1)
 		node = numa_node_id();
 
 	if (node < first_node(node_online_map))
