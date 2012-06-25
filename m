From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 2/2] be2net: Regression bug wherein VFs creation broken for multiple cards.
Date: Mon, 25 Jun 2012 11:12:00 +0530
Message-ID: <9e2293fc-c9e4-405c-b4e5-dc2ae8ab96da@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:3573 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab2FYFpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 01:45:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix be_find_vfs() to check for matching bus number as well along with devfn

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 21e0b5b..4836cc5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1059,7 +1059,8 @@ static int be_find_vfs(struct be_adapter *adapter, int vf_state)
 	dev = pci_get_device(pdev->vendor, PCI_ANY_ID, NULL);
 	while (dev) {
 		vf_fn = (pdev->devfn + offset + stride * vfs) & 0xFFFF;
-		if (dev->is_virtfn && dev->devfn == vf_fn) {
+		if (dev->is_virtfn && dev->devfn == vf_fn &&
+			dev->bus->number == pdev->bus->number) {
 			vfs++;
 			if (dev->dev_flags & PCI_DEV_FLAGS_ASSIGNED)
 				assigned_vfs++;
-- 
1.5.6.1
