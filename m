From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] tg3 PXE-related fix
Date: Tue, 26 Nov 2002 18:58:20 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DE40A9C.8070109@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090203060400040805000308"
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090203060400040805000308
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Thanks to Manish Lachwani for isolating the area for this fix, which 
will get checked in soon after some more testing.  Fix originated from 
the Broadcom driver, via Manish's kind help.

Posted mainly in case other netdev'izens with BCM5704 A0 chips are 
running into this.

Patch against 2.4.20-rc[34]'s tg3.c, a.k.a. version 1.2.

--------------090203060400040805000308
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	Mon Nov 25 18:53:36 2002
+++ b/drivers/net/tg3.c	Mon Nov 25 18:53:36 2002
@@ -6182,6 +6182,13 @@
 	if ((pci_state_reg & PCISTATE_BUS_32BIT) != 0)
 		tp->tg3_flags |= TG3_FLAG_PCI_32BIT;
 
+	/* Chip-specific fixup from Broadcom driver */
+	if ((tp->pci_chip_rev_id == CHIPREV_ID_5704_A0) &&
+	    (!(pci_state_reg & PCISTATE_RETRY_SAME_DMA))) {
+		pci_state_reg |= PCISTATE_RETRY_SAME_DMA;
+		pci_write_config_dword(tp->pdev, TG3PCI_PCISTATE, pci_state_reg);
+	}
+
 	/* Force the chip into D0. */
 	err = tg3_set_power_state(tp, 0);
 	if (err)

--------------090203060400040805000308--
