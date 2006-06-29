From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 14 of 39] IB/ipath - removed unused
 field ipath_kregvirt from struct ipath_devdata
Date: Thu, 29 Jun 2006 14:41:05 -0700
Message-ID: <e43b4df874a97ae8bfc9.1151617265@eng-12.pathscale.com>
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

diff -r a94e9f9c9c23 -r e43b4df874a9 drivers/infiniband/hw/ipath/ipath_driver.c
--- a/drivers/infiniband/hw/ipath/ipath_driver.c	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_driver.c	Thu Jun 29 14:33:25 2006 -0700
@@ -496,10 +496,8 @@ static int __devinit ipath_init_one(stru
 		((void __iomem *)dd->ipath_kregbase + len);
 	dd->ipath_physaddr = addr;	/* used for io_remap, etc. */
 	/* for user mmap */
-	dd->ipath_kregvirt = (u64 __iomem *) phys_to_virt(addr);
-	ipath_cdbg(VERBOSE, "mapped io addr %llx to kregbase %p "
-		   "kregvirt %p\n", addr, dd->ipath_kregbase,
-		   dd->ipath_kregvirt);
+	ipath_cdbg(VERBOSE, "mapped io addr %llx to kregbase %p\n",
+		   addr, dd->ipath_kregbase);
 
 	/*
 	 * clear ipath_flags here instead of in ipath_init_chip as it is set
@@ -1809,7 +1807,6 @@ static void cleanup_device(struct ipath_
 			 * re-init
 			 */
 			dd->ipath_kregbase = NULL;
-			dd->ipath_kregvirt = NULL;
 			dd->ipath_uregbase = 0;
 			dd->ipath_sregbase = 0;
 			dd->ipath_cregbase = 0;
diff -r a94e9f9c9c23 -r e43b4df874a9 drivers/infiniband/hw/ipath/ipath_kernel.h
--- a/drivers/infiniband/hw/ipath/ipath_kernel.h	Thu Jun 29 14:33:25 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_kernel.h	Thu Jun 29 14:33:25 2006 -0700
@@ -158,11 +158,6 @@ struct ipath_devdata {
 	unsigned long ipath_physaddr;
 	/* base of memory alloced for ipath_kregbase, for free */
 	u64 *ipath_kregalloc;
-	/*
-	 * version of kregbase that doesn't have high bits set (for 32 bit
-	 * programs, so mmap64 44 bit works)
-	 */
-	u64 __iomem *ipath_kregvirt;
 	/*
 	 * virtual address where port0 rcvhdrqtail updated for this unit.
 	 * only written to by the chip, not the driver.
