From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Make z8530.c build on 2.6
Date: Wed, 13 Aug 2003 13:25:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030813132501.01eb1ecf.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jeff Garzik <jgarzik@pobox.com>,
   Nenad Corbic <ncorbic@sangoma.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Either we need to mark this driver (and the parts that use them) as BROKEN,
or at least get it building again.

With this it builds, but of course, I don't have the real hardware.

diff -Nru a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
--- a/drivers/net/wan/z85230.c	Wed Aug 13 13:17:33 2003
+++ b/drivers/net/wan/z85230.c	Wed Aug 13 13:17:33 2003
@@ -890,12 +890,12 @@
 	if(c->mtu  > PAGE_SIZE/2)
 		return -EMSGSIZE;
 	 
-	c->rx_buf[0]=(void *)get_free_page(GFP_KERNEL|GFP_DMA);
+	c->rx_buf[0]=(void *)get_zeroed_page(GFP_KERNEL|GFP_DMA);
 	if(c->rx_buf[0]==NULL)
 		return -ENOBUFS;
 	c->rx_buf[1]=c->rx_buf[0]+PAGE_SIZE/2;
 	
-	c->tx_dma_buf[0]=(void *)get_free_page(GFP_KERNEL|GFP_DMA);
+	c->tx_dma_buf[0]=(void *)get_zeroed_page(GFP_KERNEL|GFP_DMA);
 	if(c->tx_dma_buf[0]==NULL)
 	{
 		free_page((unsigned long)c->rx_buf[0]);
@@ -1080,7 +1080,7 @@
 	if(c->mtu  > PAGE_SIZE/2)
 		return -EMSGSIZE;
 	 
-	c->tx_dma_buf[0]=(void *)get_free_page(GFP_KERNEL|GFP_DMA);
+	c->tx_dma_buf[0]=(void *)get_zeroed_page(GFP_KERNEL|GFP_DMA);
 	if(c->tx_dma_buf[0]==NULL)
 		return -ENOBUFS;
 
