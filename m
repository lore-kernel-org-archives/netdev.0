From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/7] skge: rearrange fields
Date: Fri, 16 Mar 2007 14:01:31 -0700
Message-ID: <20070316210156.183648598@linux-foundation.org>
References: <20070316210125.324052637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36160 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965933AbXCPVGc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 17:06:32 -0400
Content-Disposition: inline; filename=skge-mem-opt.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do some minor rearrangement of data structures to try and optimize
cache usage.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.h |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

--- skge-dev.orig/drivers/net/skge.h
+++ skge-dev/drivers/net/skge.h
@@ -2446,15 +2446,15 @@ enum pause_status {
 
 
 struct skge_port {
-	u32		     msg_enable;
 	struct skge_hw	     *hw;
 	struct net_device    *netdev;
 	int		     port;
+	u32		     msg_enable;
 
 	struct skge_ring     tx_ring;
-	struct skge_ring     rx_ring;
 
-	struct net_device_stats net_stats;
+	struct skge_ring     rx_ring ____cacheline_aligned_in_smp;
+	unsigned int	     rx_buf_size;
 
 	struct timer_list    link_timer;
 	enum pause_control   flow_control;
@@ -2470,7 +2470,8 @@ struct skge_port {
 	void		     *mem;	/* PCI memory for rings */
 	dma_addr_t	     dma;
 	unsigned long	     mem_size;
-	unsigned int	     rx_buf_size;
+
+	struct net_device_stats net_stats;
 };
 
 

-- 

