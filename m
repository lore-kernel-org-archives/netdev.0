From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/3] igb: allow vlan devices to use TSO and TCP CSUM offload
Date: Thu, 05 Jun 2008 04:06:27 -0700
Message-ID: <20080605110535.28781.92073.stgit@localhost.localdomain>
References: <20080605105954.28781.95876.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8077 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753436AbYFELGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 07:06:40 -0400
In-Reply-To: <20080605105954.28781.95876.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the new interface for propagating device feature flags into VLAN
deivces, turn on TSO and CSUM offload on VLAN devices.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ae398f0..7b6b780 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -967,8 +967,13 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 			   NETIF_F_HW_VLAN_FILTER;
 
 	netdev->features |= NETIF_F_TSO;
-
 	netdev->features |= NETIF_F_TSO6;
+
+	netdev->vlan_features |= NETIF_F_TSO;
+	netdev->vlan_features |= NETIF_F_TSO6;
+	netdev->vlan_features |= NETIF_F_HW_CSUM;
+	netdev->vlan_features |= NETIF_F_SG;
+
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 

