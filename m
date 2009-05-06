From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/5] ixgbe: Return PCI_ERS_RESULT_DISCONNECT when
	bus is disabled
Date: Wed, 06 May 2009 13:44:26 -0700
Message-ID: <20090506204425.18071.23427.stgit@localhost.localdomain>
References: <20090506204317.18071.96421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:42267
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932278AbZEFUon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:44:43 -0400
In-Reply-To: <20090506204317.18071.96421.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Breno Leitao <leitao@linux.vnet.ibm.com>

According to the "PCI Error Recovery" document, if after a recovery,
the bus is disabled, the error_detected function should return
PCI_ERS_RESULT_DISCONNECT. Actually ixgbe error_detected function is
always returning PCI_ERS_RESULT_NEED_RESET, even if the bus is in failure.
This patch just check if the bus is disabled and then returns
PCI_ERS_RESULT_DISCONNET.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2c70fa0..dd56adb 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5145,6 +5145,9 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 
 	netif_device_detach(netdev);
 
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	if (netif_running(netdev))
 		ixgbe_down(adapter);
 	pci_disable_device(pdev);

