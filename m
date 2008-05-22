From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH RESEND] atl1: fix 4G memory corruption bug
Date: Fri, 23 May 2008 02:00:25 +0400
Message-ID: <20080522220025.GA566@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jay Cliburn <jacliburn@bellsouth.net>, stable@kernel.org
To: jeff@garzik.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761612AbYEVVEs@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>

When using 4+ GB RAM and SWIOTLB is active, the driver corrupts
memory by writing an skb after the relevant DMA page has been
unmapped.  Although this doesn't happen when *not* using bounce
buffers, clearing the pointer to the DMA page after unmapping
it fixes the problem.

http://marc.info/?t=120861317000005&r=2&w=2


Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atlx/atl1.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2027,6 +2027,7 @@ rrd_ok:
 		/* Good Receive */
 		pci_unmap_page(adapter->pdev, buffer_info->dma,
 			       buffer_info->length, PCI_DMA_FROMDEVICE);
+		buffer_info->dma = 0;
 		skb = buffer_info->skb;
 		length = le16_to_cpu(rrd->xsz.xsum_sz.pkt_size);
 
