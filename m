From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 02/10] e100: make sure vlan support isn't advertised on old adapters
Date: Wed,  2 Nov 2011 17:19:53 -0700
Message-ID: <1320279601-1276-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Michael Tokarev <mjt@tls.msk.ru>,
	David Lamparter <equinox@diac24.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37902 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754305Ab1KCAUE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 20:20:04 -0400
In-Reply-To: <1320279601-1276-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

e100 parts don't support vlan offload but they generally do
allow use of vlans in higher software layers via the 8021q module.
That said, there are a couple of really old revisions of e100
hardware that don't even allow the longer frame sizes
required for vlan use with standard MTU.

Use the VLAN_CHALLENGED flag to prevent vlan binding to these
devices.

Reported-by: Michael Tokarev <mjt@tls.msk.ru>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Michael Tokarev <mjt@tls.msk.ru>
CC: David Lamparter <equinox@diac24.net>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index ae17cd1..5a2fdf7 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2810,6 +2810,10 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 
 	e100_get_defaults(nic);
 
+	/* D100 MAC doesn't allow rx of vlan packets with normal MTU */
+	if (nic->mac < mac_82558_D101_A4)
+		netdev->features |= NETIF_F_VLAN_CHALLENGED;
+
 	/* locks must be initialized before calling hw_reset */
 	spin_lock_init(&nic->cb_lock);
 	spin_lock_init(&nic->cmd_lock);
-- 
1.7.6.4
