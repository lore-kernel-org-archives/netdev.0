From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 67/75] et131x: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:39 +0100
Message-ID: <1313760467-8598-67-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Ian Campbell <ian.campbell@citrix.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	linux-kernel@vger.kernel.org, Alan Cox <alan@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Mark Einon <mark.einon@gmail.com>
Cc: Alan Cox <alan@linux.intel.com>
Cc: devel@driverdev.osuosl.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/staging/et131x/et1310_tx.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/et131x/et1310_tx.c b/drivers/staging/et131x/et1310_tx.c
index 8fb3051..03e7a4e 100644
--- a/drivers/staging/et131x/et1310_tx.c
+++ b/drivers/staging/et131x/et1310_tx.c
@@ -519,12 +519,12 @@ static int nic_send_packet(struct et131x_adapter *etdev, struct tcb *tcb)
 			 * returned by pci_map_page() is always 32-bit
 			 * addressable (as defined by the pci/dma subsystem)
 			 */
-			desc[frag++].addr_lo =
-			    pci_map_page(etdev->pdev,
-					 frags[i - 1].page,
-					 frags[i - 1].page_offset,
-					 frags[i - 1].size,
-					 PCI_DMA_TODEVICE);
+			desc[frag++].addr_lo = skb_frag_dma_map(
+							&etdev->pdev->dev,
+							&frags[i - 1],
+							0,
+							frags[i - 1].size,
+							PCI_DMA_TODEVICE);
 		}
 	}
 
-- 
1.7.2.5
