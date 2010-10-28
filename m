From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igbvf: fix panic on load
Date: Thu, 28 Oct 2010 03:59:51 -0700
Message-ID: <20101028105951.27748.36868.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Greg Rose <greg.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:46415
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757217Ab0J1K7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 06:59:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Introduced by commit:e6484930d7c73d324bccda7d43d131088da697b9
net: allocate tx queues in register_netdevice

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Greg Rose <greg.v.rose@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/netdev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index ebfaa68..28af019 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2783,15 +2783,15 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	/* reset the hardware with the new settings */
 	igbvf_reset(adapter);
 
-	/* tell the stack to leave us alone until igbvf_open() is called */
-	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
-
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
 	if (err)
 		goto err_hw_init;
 
+	/* tell the stack to leave us alone until igbvf_open() is called */
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
 	igbvf_print_device_info(adapter);
 
 	igbvf_initialize_last_counter_stats(adapter);

