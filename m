From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TG3] Always load TSO firmware
Date: Mon, 17 Nov 2003 20:32:25 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117093225.GA12420@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="HlL+5n6rz5pIUxbD"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

In 2.5 the TSO firmware is always loaded on capable cards.  This
does not happen in 2.4.  I've received a report from a Broadcom
5705M user that unless the firmware is loaded his card does not
work.

This patch makes it load the TSO firmware even if the kernel
does not support it.

The only catch is that the Broadcom driver doesn't always load
the firmware either and yet it still works under 2.4 for that user.

Despite that this should still be safe as 2.5 always loads the
firmware regardless of whether TSO is going to be used or not.
It also removes another variable between 2.4/2.5 when chasing
down tg3 bugs.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tg3.patch"

Index: kernel-source-2.5/drivers/net/tg3.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/tg3.c,v
retrieving revision 1.2
diff -u -r1.2 tg3.c
--- kernel-source-2.5/drivers/net/tg3.c	12 Nov 2003 10:50:39 -0000	1.2
+++ kernel-source-2.5/drivers/net/tg3.c	17 Nov 2003 08:30:18 -0000
@@ -3857,8 +3857,6 @@
 	return 0;
 }
 
-#if TG3_TSO_SUPPORT != 0
-
 #define TG3_TSO_FW_RELEASE_MAJOR	0x1
 #define TG3_TSO_FW_RELASE_MINOR		0x3
 #define TG3_TSO_FW_RELEASE_FIX		0x0
@@ -4445,8 +4443,6 @@
 	return 0;
 }
 
-#endif /* TG3_TSO_SUPPORT != 0 */
-
 /* tp->lock is held. */
 static void __tg3_set_mac_addr(struct tg3 *tp)
 {
@@ -4644,7 +4640,6 @@
 		tw32(BUFMGR_DMA_DESC_POOL_ADDR, NIC_SRAM_DMA_DESC_POOL_BASE);
 		tw32(BUFMGR_DMA_DESC_POOL_SIZE, NIC_SRAM_DMA_DESC_POOL_SIZE);
 	}
-#if TG3_TSO_SUPPORT != 0
 	else if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
 		int fw_len;
 
@@ -4659,7 +4654,6 @@
 		tw32(BUFMGR_MB_POOL_SIZE,
 		     NIC_SRAM_MBUF_POOL_SIZE5705 - fw_len - 0xa00);
 	}
-#endif
 
 	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_ENABLE)) {
 		tw32(BUFMGR_MB_RDMA_LOW_WATER,
@@ -5005,13 +4999,11 @@
 			return err;
 	}
 
-#if TG3_TSO_SUPPORT != 0
 	if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) {
 		err = tg3_load_tso_firmware(tp);
 		if (err)
 			return err;
 	}
-#endif
 
 	tp->tx_mode = TX_MODE_ENABLE;
 	tw32(MAC_TX_MODE, tp->tx_mode);
@@ -7649,7 +7641,6 @@
 			DEFAULT_MB_HIGH_WATER_5705;
 	}
 
-#if TG3_TSO_SUPPORT != 0
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
 	    tp->pci_chip_rev_id == CHIPREV_ID_5705_A0 ||
@@ -7666,8 +7657,6 @@
 		dev->features |= NETIF_F_TSO;
 #endif
 
-#endif
-
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 &&
 	    !(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) &&
 	    !(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH)) {

--HlL+5n6rz5pIUxbD--
