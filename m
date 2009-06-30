From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 4/5] e1000: return PCI_ERS_RESULT_DISCONNECT on
	permanent error
Date: Tue, 30 Jun 2009 15:46:13 -0700
Message-ID: <20090630224612.17771.38476.stgit@localhost.localdomain>
References: <20090630224515.17771.76848.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Andre Detsch <adetsch@br.ibm.com>,
	Mike Mason <mmlnx@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:60786
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754320AbZF3Wqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 18:46:30 -0400
In-Reply-To: <20090630224515.17771.76848.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andre Detsch <adetsch@br.ibm.com>

PCI drivers that implement the io_error_detected callback
should return PCI_ERS_RESULT_DISCONNECT if the state
passed in is pci_channel_io_perm_failure.  This state is
not checked in many of the network drivers.

The patch fixes the omission in the e1000 driver.

Based on Mike Mason's similar patch for e1000e.

Signed-off-by: Andre Detsch <adetsch@br.ibm.com>
CC: Mike Mason <mmlnx@us.ibm.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 972e06d..5b8cbdb 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4823,6 +4823,9 @@ static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
 
 	netif_device_detach(netdev);
 
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	if (netif_running(netdev))
 		e1000_down(adapter);
 	pci_disable_device(pdev);

