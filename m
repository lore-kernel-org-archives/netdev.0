From: Dean Nelson <dnelson@redhat.com>
Subject: [PATCH net-next] e1000e: restore call to pci_clear_master()
Date: Wed, 12 Jun 2013 13:47:47 -0400
Message-ID: <20130612174747.7449.40767.email-sent-by-dnelson@teal>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kersher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754886Ab3FLRsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 13:48:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In attempting to resolve a minor merge conflict, commit e5f2ef7ab4690d2e8faa
accidently dropped a call to pci_clear_master() that was intended to remain
in place.

Commit 4e0855dff094b0d56d6b replaced a call to pci_disable_device() by one to
pci_clear_master(). And then commit 66148babe728f3e00e13 deleted a number of
lines starting two lines following that call.

This patch restores the call to pci_clear_master() in __e1000_shutdown().

Signed-off-by: Dean Nelson <dnelson@redhat.com>
---
Both stable 3.8.y and 3.9.y appear to have the call to pci_clear_master() in
__e1000_shutdown() as desired.  I'm not sure how they avoided the conflict.

 drivers/net/ethernet/intel/e1000e/netdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 77f81cb..5475cf4 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5995,6 +5995,8 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 	 */
 	e1000e_release_hw_control(adapter);
 
+	pci_clear_master(pdev);
+
 	/* The pci-e switch on some quad port adapters will report a
 	 * correctable error when the MAC transitions from D0 to D3.  To
 	 * prevent this we need to mask off the correctable errors on the
