From: Olaf Hering <olaf@aepfle.de>
Subject: [PATCH] fix MCA when shutting down tulip quad-NIC
Date: Tue, 3 Apr 2007 23:19:16 +0200
Message-ID: <20070403211916.GA25570@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: val_henson@linux.intel.com, andrew.patterson@hp.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:38772 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945953AbXDCVTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 17:19:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: andrew.patterson@hp.com

 https://bugzilla.novell.com/show_bug.cgi?id=SUSE39204

Shutting down the network causes an MCA because of an IO TLB error when
a DEC quad 10/100 card is in any slot.  This problem was originally seen
on an HP rx4640.


Signed-off-by: Olaf Hering <olaf@aepfle.de>

---

Andrew: Why is it tp->pdev instead of pdev?

 drivers/net/tulip/tulip_core.c |    1 +
 1 file changed, 1 insertion(+)

Index: b/drivers/net/tulip/tulip_core.c
===================================================================
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1798,6 +1798,7 @@ static void __devexit tulip_remove_one (
 		return;
 
 	tp = netdev_priv(dev);
+	pci_disable_device(tp->pdev);
 	unregister_netdev(dev);
 	pci_free_consistent (pdev,
 			     sizeof (struct tulip_rx_desc) * RX_RING_SIZE +
