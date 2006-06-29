From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 15 of 39] IB/ipath - print better debug
 info when handling 32/64-bit DMA mask problems
Date: Thu, 29 Jun 2006 14:41:06 -0700
Message-ID: <125471ee6c6863fbfa35.1151617266@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org,
	rdreier@cisco.com,
	mst@mellanox.co.il
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Dave Olson <dave.olson@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r e43b4df874a9 -r 125471ee6c68 drivers/infiniband/hw/ipath/ipath_driver.c
--- a/drivers/infiniband/hw/ipath/ipath_driver.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_driver.c	Thu Jun 29 14:33:25 2006 -0700
@@ -425,12 +425,29 @@ static int __devinit ipath_init_one(stru
 		 */
 		ret = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (ret) {
-			dev_info(&pdev->dev, "pci_set_dma_mask unit %u "
-				 "fails: %d\n", dd->ipath_unit, ret);
+			dev_info(&pdev->dev,
+				"Unable to set DMA mask for unit %u: %d\n",
+				dd->ipath_unit, ret);
 			goto bail_regions;
 		}
-		else
+		else {
 			ipath_dbg("No 64bit DMA mask, used 32 bit mask\n");
+			ret = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			if (ret)
+				dev_info(&pdev->dev,
+					"Unable to set DMA consistent mask "
+					"for unit %u: %d\n",
+					dd->ipath_unit, ret);
+
+		}
+	}
+	else {
+		ret = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		if (ret)
+			dev_info(&pdev->dev,
+				"Unable to set DMA consistent mask "
+				"for unit %u: %d\n",
+				dd->ipath_unit, ret);
 	}
 
 	pci_set_master(pdev);
