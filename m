From: "Stanislav O\. Bezzubtsev" <stas@lvk.cs.msu.su>
Subject: [PATCH] forcedeth: mac address fix
Date: Sat, 14 Nov 2009 11:31:25 +0300
Message-ID: <1258187485-11549-1-git-send-email-stas@lvk.cs.msu.su>
Cc: davem@davemloft.net, aabdulla@nvidia.com, yinghai@kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Stanislav O\. Bezzubtsev" <stas@lvk.cs.msu.su>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.lvk.cs.msu.su ([158.250.17.1]:49959 "EHLO
	mail.lvk.cs.msu.su" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbZKNIbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 03:31:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the existing random_ether_addr() to generate random MAC
instead of doing it by-hand.

Signed-off-by: Stanislav O. Bezzubtsev <stas@lvk.cs.msu.su>
---
 drivers/net/forcedeth.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index e1da466..3116601 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5821,10 +5821,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		        dev->dev_addr);
 		dev_printk(KERN_ERR, &pci_dev->dev,
 			"Please complain to your hardware vendor. Switching to a random MAC.\n");
-		dev->dev_addr[0] = 0x00;
-		dev->dev_addr[1] = 0x00;
-		dev->dev_addr[2] = 0x6c;
-		get_random_bytes(&dev->dev_addr[3], 3);
+		random_ether_addr(dev->dev_addr);
 	}
 
 	dprintk(KERN_DEBUG "%s: MAC Address %pM\n",
-- 
1.6.5

