From: akpm@linux-foundation.org
Subject: [patch 06/18] PCI-X/PCI-Express read control interfaces: use them in myrinet
Date: Fri, 10 Aug 2007 14:05:17 -0700
Message-ID: <200708102105.l7AL5H0a008960@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	peter.oruba@amd.com, brice@myri.com, rolandd@cisco.com,
	shemminger@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48590 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758841AbXHJVG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:06:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Peter Oruba" <peter.oruba@amd.com>

These driver changes incorporate the proposed PCI-X / PCI-Express read byte
count interface.  Reading and setting those valuse doesn't take place
"manually", instead wrapping functions are called to allow quirks for some
PCI bridges.

Signed-off by: Peter Oruba <peter.oruba@amd.com>
Based on work by Stephen Hemminger <shemminger@linux-foundation.org>
Cc: Roland Dreier <rolandd@cisco.com>
Cc: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/myri10ge/myri10ge.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/myri10ge/myri10ge.c~pci-x-pci-express-read-control-interfaces-myrinet drivers/net/myri10ge/myri10ge.c
--- a/drivers/net/myri10ge/myri10ge.c~pci-x-pci-express-read-control-interfaces-myrinet
+++ a/drivers/net/myri10ge/myri10ge.c
@@ -2884,8 +2884,7 @@ static int myri10ge_probe(struct pci_dev
 			status);
 		goto abort_with_netdev;
 	}
-	val = (val & ~PCI_EXP_DEVCTL_READRQ) | (5 << 12);
-	status = pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL, val);
+	status = pcie_set_readrq(pdev, 4096);
 	if (status != 0) {
 		dev_err(&pdev->dev, "Error %d writing PCI_EXP_DEVCTL\n",
 			status);
_
