From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] 3c59x: Don't assign when a comparison is intended
Date: Sat, 25 Dec 2010 21:30:08 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012252125410.10759@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: vortex@scyld.com, becker@scyld.com,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:16177 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab0LYUjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 15:39:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In drivers/net/3c59x.c::vortex_probe1() we have this code:

        if (gendev) {
                if ((pdev = DEVICE_PCI(gendev))) {
                        print_name = pci_name(pdev);
                }

                if ((edev = DEVICE_EISA(gendev))) {
                        print_name = dev_name(&edev->dev);
                }
        }

I believe these assignments were intended to be comparisons.
If I'm correct, then here's a patch to fix that up.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 3c59x.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 0a92436f..db8a80e 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1110,11 +1110,11 @@ static int __devinit vortex_probe1(struct device *gendev,
 	}
 
 	if (gendev) {
-		if ((pdev = DEVICE_PCI(gendev))) {
+		if ((pdev == DEVICE_PCI(gendev))) {
 			print_name = pci_name(pdev);
 		}
 
-		if ((edev = DEVICE_EISA(gendev))) {
+		if ((edev == DEVICE_EISA(gendev))) {
 			print_name = dev_name(&edev->dev);
 		}
 	}


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

