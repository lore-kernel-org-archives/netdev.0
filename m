From: "Bryan O'Sullivan" <bos@pathscale.com>
Subject: [PATCH 25 of 39] IB/ipath - removed redundant
 statements
Date: Thu, 29 Jun 2006 14:41:16 -0700
Message-ID: <4c581c37bb95ad3abb6d.1151617276@eng-12.pathscale.com>
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

The tail register read became redundant as the result of earlier receive
interrupt bug fixes.

Drop another unneeded register read.

And another line that got duplicated.

Signed-off-by: Dave Olson <dave.olson@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r e952aedb0e94 -r 4c581c37bb95 drivers/infiniband/hw/ipath/ipath_driver.c
--- a/drivers/infiniband/hw/ipath/ipath_driver.c	Thu Jun 29 14:33:26 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_driver.c	Thu Jun 29 14:33:26 2006 -0700
@@ -890,9 +890,6 @@ void ipath_kreceive(struct ipath_devdata
 		goto done;
 
 reloop:
-	/* read only once at start for performance */
-	hdrqtail = (u32)le64_to_cpu(*dd->ipath_hdrqtailptr);
-
 	for (i = 0; l != hdrqtail; i++) {
 		u32 qp;
 		u8 *bthbytes;
diff -r e952aedb0e94 -r 4c581c37bb95 drivers/infiniband/hw/ipath/ipath_ht400.c
--- a/drivers/infiniband/hw/ipath/ipath_ht400.c	Thu Jun 29 14:33:26 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_ht400.c	Thu Jun 29 14:33:26 2006 -0700
@@ -1573,7 +1573,6 @@ void ipath_init_ht400_funcs(struct ipath
 	dd->ipath_f_reset = ipath_setup_ht_reset;
 	dd->ipath_f_get_boardname = ipath_ht_boardname;
 	dd->ipath_f_init_hwerrors = ipath_ht_init_hwerrors;
-	dd->ipath_f_init_hwerrors = ipath_ht_init_hwerrors;
 	dd->ipath_f_early_init = ipath_ht_early_init;
 	dd->ipath_f_handle_hwerrors = ipath_ht_handle_hwerrors;
 	dd->ipath_f_quiet_serdes = ipath_ht_quiet_serdes;
diff -r e952aedb0e94 -r 4c581c37bb95 drivers/infiniband/hw/ipath/ipath_intr.c
--- a/drivers/infiniband/hw/ipath/ipath_intr.c	Thu Jun 29 14:33:26 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_intr.c	Thu Jun 29 14:33:26 2006 -0700
@@ -824,7 +824,6 @@ irqreturn_t ipath_intr(int irq, void *da
 			ipath_stats.sps_fastrcvint++;
 			goto done;
 		}
-		istat = ipath_read_kreg32(dd, dd->ipath_kregs->kr_intstatus);
 	}
  
 	istat = ipath_read_kreg32(dd, dd->ipath_kregs->kr_intstatus);
