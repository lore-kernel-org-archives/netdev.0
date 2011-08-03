From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/6] be2net: remove wrong and unnecessary calls to netif_carrier_off()
Date: Wed, 3 Aug 2011 11:27:41 +0530
Message-ID: <1312351066-16745-2-git-send-email-sathya.perla@emulex.com>
References: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:24506 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754454Ab1HCF4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 01:56:30 -0400
In-Reply-To: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) In be_probe(), as soon as the MCC Q is created a gratuitous link status
event is received and processed. Accordingly netif_carrier_off/on() is called.
The extra netif_carrier_off() call in probe can race with this and cause wrong
state.

2) be_close() need not call netif_carrier_off(). It is OK to show the actual
link state even when the device is administratively down.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9f2f66c..553cc0d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2217,7 +2217,6 @@ static int be_close(struct net_device *netdev)
 
 	be_async_mcc_disable(adapter);
 
-	netif_carrier_off(netdev);
 	adapter->link_up = false;
 
 	if (!lancer_chip(adapter))
@@ -3345,7 +3344,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	status = register_netdev(netdev);
 	if (status != 0)
 		goto unsetup;
-	netif_carrier_off(netdev);
 
 	if (be_physfn(adapter) && adapter->sriov_enabled) {
 		u8 mac_speed;
-- 
1.7.4

