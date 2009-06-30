From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/5] e1000e: io_error_detected callback should return
	PCI_ERS_RESULT_DISCONNECT
Date: Tue, 30 Jun 2009 15:45:53 -0700
Message-ID: <20090630224553.17771.97028.stgit@localhost.localdomain>
References: <20090630224515.17771.76848.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mike Mason <mmlnx@us.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:39287
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754088AbZF3WqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 18:46:09 -0400
In-Reply-To: <20090630224515.17771.76848.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Mason <mmlnx@us.ibm.com>

on permanent failure

PCI drivers that implement the io_error_detected callback
should return PCI_ERS_RESULT_DISCONNECT if the state
passed in is pci_channel_io_perm_failure.  This state is not
checked in many of the network drivers.

This patch fixes the omission in the e1000e driver.

Signed-off-by: Mike Mason <mmlnx@us.ibm.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 679885a..63415bb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4785,6 +4785,9 @@ static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
 
 	netif_device_detach(netdev);
 
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	if (netif_running(netdev))
 		e1000e_down(adapter);
 	pci_disable_device(pdev);

