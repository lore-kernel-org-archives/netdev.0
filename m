From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc4-bk3-netdev3 1/3] r8169: always clean Tx desc
Date: Tue, 19 Oct 2004 01:08:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018230823.GB19990@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

rtl8169_unmap_tx_skb() can not assume that a Tx ring descriptor belongs
to the host as it can be issued during rtl8169_tx_clear() as a part of
a recovery process (during Tx timeout for instance).

Simple fix: always clean the relevant descriptor entry.

Acked-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jon Mason <jdmason@us.ibm.com>

diff -puN drivers/net/r8169.c~r8169-225 drivers/net/r8169.c
--- linux-2.6.9/drivers/net/r8169.c~r8169-225	2004-10-18 22:13:54.000000000 +0200
+++ linux-2.6.9-fr/drivers/net/r8169.c	2004-10-18 23:31:21.000000000 +0200
@@ -1679,6 +1679,7 @@ static void rtl8169_unmap_tx_skb(struct 
 	unsigned int len = tx_skb->len;
 
 	pci_unmap_single(pdev, le64_to_cpu(desc->addr), len, PCI_DMA_TODEVICE);
+	desc->opts1 = 0x00;
 	desc->opts2 = 0x00;
 	desc->addr = 0x00;
 	tx_skb->len = 0;

_
