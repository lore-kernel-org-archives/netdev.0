From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 5/5] igb: return PCI_ERS_RESULT_DISCONNECT on
	permanent error
Date: Tue, 30 Jun 2009 15:46:34 -0700
Message-ID: <20090630224633.17771.74883.stgit@localhost.localdomain>
References: <20090630224515.17771.76848.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:52465
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755978AbZF3Wqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 18:46:49 -0400
In-Reply-To: <20090630224515.17771.76848.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

PCI drivers that implement the io_error_detected callback should return
PCI_ERS_RESULT_DISCONNECT if the state passed in is
pci_channel_io_perm_failure.  This patch fixes the issue for igb.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 468356d..be48029 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5339,6 +5339,9 @@ static pci_ers_result_t igb_io_error_detected(struct pci_dev *pdev,
 
 	netif_device_detach(netdev);
 
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	if (netif_running(netdev))
 		igb_down(adapter);
 	pci_disable_device(pdev);

