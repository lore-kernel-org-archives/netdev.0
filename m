From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Wed, 26 May 2004 11:47:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526114714.23fcf37d.davem@redhat.com>
References: <B1508D50A0692F42B217C22C02D849727FEDBE@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gnb@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D849727FEDBE@NT-IRVA-0741.brcm.ad.broadcom.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 26 May 2004 10:43:10 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> I would recommend tg3 to make the switch also.

Ok, I'll make it use DMA tx descriptors by default.

The checking for cases where we can't do on-chip TX desciptors
I'll keep around (albeit commented out) just in case we allow
this again in the future.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/26 11:46:50-07:00 davem@nuts.davemloft.net 
#   [TG3]: Use HOST TXDs always.
# 
# drivers/net/tg3.c
#   2004/05/26 11:46:42-07:00 davem@nuts.davemloft.net +9 -0
#   [TG3]: Use HOST TXDs always.
# 
diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2004-05-26 11:46:57 -07:00
+++ b/drivers/net/tg3.c	2004-05-26 11:46:57 -07:00
@@ -7534,6 +7534,14 @@
 	udelay(50);
 	tg3_nvram_init(tp);
 
+	/* Always use host TXDs, it performs better in particular
+	 * with multi-frag packets.  The tests below are kept here
+	 * as documentation should we change this decision again
+	 * in the future.
+	 */
+	tp->tg3_flags |= TG3_FLAG_HOST_TXDS;
+
+#if 0
 	/* Determine if TX descriptors will reside in
 	 * main memory or in the chip SRAM.
 	 */
@@ -7541,6 +7549,7 @@
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750)
 		tp->tg3_flags |= TG3_FLAG_HOST_TXDS;
+#endif
 
 	grc_misc_cfg = tr32(GRC_MISC_CFG);
 	grc_misc_cfg &= GRC_MISC_CFG_BOARD_ID_MASK;
