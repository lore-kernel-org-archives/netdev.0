From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 3/32] rt2x00: use pci_*_consistent for DMA mapping
Date: Fri, 28 Apr 2006 00:02:52 +0200
Message-ID: <200604280002.52839.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1295143.I6kB5pOMV5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.188]:30060 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751776AbWD0WBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:45 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463863nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:44 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1295143.I6kB5pOMV5
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

From: Ivo van Doorn <IvDoorn@gmail.com>

Add linux/dma-mapping.h header to allow compilation
on some architectures. Instead of dma_*_coherent
use pci_*consistent functions.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-04-27 21:36:17.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-04-27 21:37:02.000000000 +0200
@@ -29,6 +29,7 @@
 #include <linux/version.h>
 #include <linux/init.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/delay.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
@@ -928,8 +929,8 @@ rt2400pci_alloc_ring(
 	/*
 	 * Allocate DMA memory for descriptor and buffer.
 	 */
-	ring->data_addr = dma_alloc_coherent(&rt2x00pci->pci_dev->dev,
-		rt2x00_get_ring_size(ring), &ring->data_dma, GFP_KERNEL);
+	ring->data_addr = pci_alloc_consistent(rt2x00pci->pci_dev,
+		rt2x00_get_ring_size(ring), &ring->data_dma);
 	if (!ring->data_addr) {
 		kfree(ring->entry);
 		return -ENOMEM;
@@ -959,7 +960,7 @@ static void
 rt2400pci_free_ring(struct rt2x00_pci *rt2x00pci, struct data_ring *ring)
 {
 	if (ring->data_addr)
-		dma_free_coherent(&rt2x00pci->pci_dev->dev,
+		pci_free_consistent(rt2x00pci->pci_dev,
 			rt2x00_get_ring_size(ring),
 			ring->data_addr, ring->data_dma);
 	ring->data_addr = NULL;
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
--- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-04-27 21:36:17.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-04-27 21:37:02.000000000 +0200
@@ -29,6 +29,7 @@
 #include <linux/version.h>
 #include <linux/init.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/delay.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
@@ -964,8 +965,8 @@ rt2500pci_alloc_ring(
 	/*
 	 * Allocate DMA memory for descriptor and buffer.
 	 */
-	ring->data_addr = dma_alloc_coherent(&rt2x00pci->pci_dev->dev,
-		rt2x00_get_ring_size(ring), &ring->data_dma, GFP_KERNEL);
+	ring->data_addr = pci_alloc_consistent(rt2x00pci->pci_dev,
+		rt2x00_get_ring_size(ring), &ring->data_dma);
 	if (!ring->data_addr) {
 		kfree(ring->entry);
 		return -ENOMEM;
@@ -995,7 +996,7 @@ static void
 rt2500pci_free_ring(struct rt2x00_pci *rt2x00pci, struct data_ring *ring)
 {
 	if (ring->data_addr)
-		dma_free_coherent(&rt2x00pci->pci_dev->dev,
+		pci_free_consistent(rt2x00pci->pci_dev,
 			rt2x00_get_ring_size(ring),
 			ring->data_addr, ring->data_dma);
 	ring->data_addr = NULL;

--nextPart1295143.I6kB5pOMV5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+MaqndE37Em0gRAkvOAKCpJE742WssMVTiwEhqFBahVMbUQgCeP68s
7NuUnHm6C/aSUl5R+XnH/+M=
=63U3
-----END PGP SIGNATURE-----

--nextPart1295143.I6kB5pOMV5--
