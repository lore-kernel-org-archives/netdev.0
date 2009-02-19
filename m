From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCHv2 11/11]Update the old macro DMA_nBIT_MASK related documentations
Date: Thu, 19 Feb 2009 17:53:26 +0800
Message-ID: <499D2C16.9050901@cn.fujitsu.com>
References: <499CFDC8.1070600@cn.fujitsu.com> <499D0221.9090407@cn.fujitsu.com> <20090219081403.GA5400@elte.hu> <499D1ED9.4040005@cn.fujitsu.com> <499D2728.1080208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60138 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752406AbZBSJwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 04:52:07 -0500
In-Reply-To: <499D2728.1080208@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the old macro DMA_nBIT_MASK related documentations

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 Documentation/DMA-mapping.txt                      |   18 +++++++++---------
 .../sound/alsa/DocBook/writing-an-alsa-driver.tmpl |    8 ++++----
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/Documentation/DMA-mapping.txt b/Documentation/DMA-mapping.txt
index b2a4d6d..01f24e9 100644
--- a/Documentation/DMA-mapping.txt
+++ b/Documentation/DMA-mapping.txt
@@ -136,7 +136,7 @@ exactly why.
 The standard 32-bit addressing PCI device would do something like
 this:
 
-	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING
 		       "mydev: No suitable DMA available.\n");
 		goto ignore_this_device;
@@ -155,9 +155,9 @@ all 64-bits when accessing streaming DMA:
 
 	int using_dac;
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		using_dac = 1;
-	} else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+	} else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		using_dac = 0;
 	} else {
 		printk(KERN_WARNING
@@ -170,14 +170,14 @@ the case would look like this:
 
 	int using_dac, consistent_using_dac;
 
-	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		using_dac = 1;
 	   	consistent_using_dac = 1;
-		pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
-	} else if (!pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
+		pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
+	} else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		using_dac = 0;
 		consistent_using_dac = 0;
-		pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+		pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	} else {
 		printk(KERN_WARNING
 		       "mydev: No suitable DMA available.\n");
@@ -192,7 +192,7 @@ check the return value from pci_set_consistent_dma_mask().
 Finally, if your device can only drive the low 24-bits of
 address during PCI bus mastering you might do something like:
 
-	if (pci_set_dma_mask(pdev, DMA_24BIT_MASK)) {
+	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(24))) {
 		printk(KERN_WARNING
 		       "mydev: 24-bit DMA addressing not available.\n");
 		goto ignore_this_device;
@@ -213,7 +213,7 @@ most specific mask.
 
 Here is pseudo-code showing how this might be done:
 
-	#define PLAYBACK_ADDRESS_BITS	DMA_32BIT_MASK
+	#define PLAYBACK_ADDRESS_BITS	DMA_BIT_MASK(32)
 	#define RECORD_ADDRESS_BITS	0x00ffffff
 
 	struct my_sound_card *card;
diff --git a/Documentation/sound/alsa/DocBook/writing-an-alsa-driver.tmpl b/Documentation/sound/alsa/DocBook/writing-an-alsa-driver.tmpl
index 87a7c07..282891c 100644
--- a/Documentation/sound/alsa/DocBook/writing-an-alsa-driver.tmpl
+++ b/Documentation/sound/alsa/DocBook/writing-an-alsa-driver.tmpl
@@ -1133,8 +1133,8 @@
           if (err < 0)
                   return err;
           /* check PCI availability (28bit DMA) */
-          if (pci_set_dma_mask(pci, DMA_28BIT_MASK) < 0 ||
-              pci_set_consistent_dma_mask(pci, DMA_28BIT_MASK) < 0) {
+          if (pci_set_dma_mask(pci, DMA_BIT_MASK(28)) < 0 ||
+              pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(28)) < 0) {
                   printk(KERN_ERR "error to set 28bit mask DMA\n");
                   pci_disable_device(pci);
                   return -ENXIO;
@@ -1248,8 +1248,8 @@
   err = pci_enable_device(pci);
   if (err < 0)
           return err;
-  if (pci_set_dma_mask(pci, DMA_28BIT_MASK) < 0 ||
-      pci_set_consistent_dma_mask(pci, DMA_28BIT_MASK) < 0) {
+  if (pci_set_dma_mask(pci, DMA_BIT_MASK(28)) < 0 ||
+      pci_set_consistent_dma_mask(pci, DMA_BIT_MASK(28)) < 0) {
           printk(KERN_ERR "error to set 28bit mask DMA\n");
           pci_disable_device(pci);
           return -ENXIO;
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
