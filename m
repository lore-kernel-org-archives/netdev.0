From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6] igb: fix i350 SR-IOV failture
Date: Tue,  7 Jun 2011 05:38:59 -0700
Message-ID: <1307450339-9889-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, stable@kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59175 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753221Ab1FGMjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:39:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Williams, Mitch A" <mitch.a.williams@intel.com>

When SR-IOV is enabled, i350 devices fail to pass traffic. This is due to
the driver attempting to enable RSS on the PF device, which is not
supported by the i350.

When max_vfs is specified on an i350 adapter, set the number of RSS queues
to 1.

This issue affects 2.6.39 as well.

CC: stable@kernel.org
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 18fccf9..2c28621 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2373,6 +2373,9 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	}
 #endif /* CONFIG_PCI_IOV */
 	adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES, num_online_cpus());
+	/* i350 cannot do RSS and SR-IOV at the same time */
+	if (hw->mac.type == e1000_i350 && adapter->vfs_allocated_count)
+		adapter->rss_queues = 1;
 
 	/*
 	 * if rss_queues > 4 or vfs are going to be allocated with rss_queues
-- 
1.7.5.2

