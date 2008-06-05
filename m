From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/3] e1000e: allow VLAN devices to use TSO and TCP CSUM offload
Date: Thu, 05 Jun 2008 04:07:28 -0700
Message-ID: <20080605110632.28781.38191.stgit@localhost.localdomain>
References: <20080605105954.28781.95876.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57381 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753676AbYFELIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 07:08:36 -0400
In-Reply-To: <20080605105954.28781.95876.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using the new interface for propagating device feature flags into VLAN
devices, turn on TSO and CSUM offload on VLAN devices.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8991ab8..fd11207 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4039,6 +4039,11 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
 
+	netdev->vlan_features |= NETIF_F_TSO;
+	netdev->vlan_features |= NETIF_F_TSO6;
+	netdev->vlan_features |= NETIF_F_HW_CSUM;
+	netdev->vlan_features |= NETIF_F_SG;
+
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 

