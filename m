From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 1/2] igb: fix hw timestamping
Date: Mon, 14 Mar 2011 22:54:23 -0700
Message-ID: <1300168464-29546-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1300168464-29546-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anders Berggren <anders@halon.se>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Anders Berggren <andfers@halon.se>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60787 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207Ab1COFy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 01:54:28 -0400
In-Reply-To: <1300168464-29546-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anders Berggren <anders@halon.se>

Hardware timestamping for Intel 82580 didn't work in either 2.6.36 or
2.6.37. Comparing it to Intel's igb-2.4.12 I found that the
timecounter_init clock/counter initialization was done too early.

Signed-off-by: Anders Berggren <andfers@halon.se>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/igb_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b4f92b0..5366f2a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -106,6 +106,7 @@ static void igb_free_all_rx_resources(struct igb_adapter *);
 static void igb_setup_mrqc(struct igb_adapter *);
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void __devexit igb_remove(struct pci_dev *pdev);
+static void igb_init_hw_timer(struct igb_adapter *adapter);
 static int igb_sw_init(struct igb_adapter *);
 static int igb_open(struct net_device *);
 static int igb_close(struct net_device *);
@@ -2048,6 +2049,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	}
 
 #endif
+	/* do hw tstamp init after resetting */
+	igb_init_hw_timer(adapter);
+
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info */
 	dev_info(&pdev->dev, "%s: (PCIe:%s:%s) %pM\n",
@@ -2384,7 +2388,6 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	igb_init_hw_timer(adapter);
 	igb_probe_vfs(adapter);
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */
-- 
1.7.4

