From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [PATCH] Fix dead 21041 ethernet after ifconfig down
Date: Fri, 12 Sep 2008 23:19:19 +0200 (CEST)
Message-ID: <20080912211919.1C36FC2AFD@solo.franken.de>
Cc: grundler@parisc-linux.org, kyle@parisc-linux.org, tbm@cyrius.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:45784 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558AbYILW3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 18:29:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The de2104x did a pci_disable_device() in it's close function, but
the open function never does a pci_enable_device() and assumes that
the device is already enabled. Considering that downing the interface
is just a temporary thing the pci_disable_device() isn't a pretty good
idea and removing it from the close function just fixes the bug.

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

 drivers/net/tulip/de2104x.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index 9281d06..f54c450 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1418,7 +1418,6 @@ static int de_close (struct net_device *dev)
 
 	de_free_rings(de);
 	de_adapter_sleep(de);
-	pci_disable_device(de->pdev);
 	return 0;
 }
 
