From: Dean Nelson <dnelson@redhat.com>
Subject: [net-next-2.6 PATCH 7/9] qlge: return PCI_ERS_RESULT_DISCONNECT on permanent failure
Date: Fri, 31 Jul 2009 15:13:48 -0400
Message-ID: <20090731191348.5470.55591.send-patch@aqua>
References: <20090731191254.5470.99642.send-patch@aqua>
Cc: linux-driver@qlogic.com, Ron Mercer <ron.mercer@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40850 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbZGaTOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2009 15:14:51 -0400
In-Reply-To: <20090731191254.5470.99642.send-patch@aqua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI drivers that implement the struct pci_error_handlers' error_detected
callback should return PCI_ERS_RESULT_DISCONNECT if the state passed in is
pci_channel_io_perm_failure. This patch fixes the issue for qlge.

Signed-off-by: Dean Nelson <dnelson@redhat.com>

---

This patch has not been tested, since I don't have the hardware to test it.
It is based on a few recent patches. See the following commits:

http://git.kernel.org/linus/c93b5a76d58656158d195a7df507ebc660010969
http://git.kernel.org/linus/eab633021c26025b34f36f79f0311d3d99f40ceb
http://git.kernel.org/linus/ef681ce1e8b3e63317cd724c200b2fd39286c005
http://git.kernel.org/linus/59ed6eecff4aa00c5c5d18ffd180acac108d596e
http://git.kernel.org/linus/3044b8d1ff8c05237652a692fb572a34e4d70146

 drivers/net/qlge/qlge_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 5768af1..3a271af 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4076,6 +4076,11 @@ static pci_ers_result_t qlge_io_error_detected(struct pci_dev *pdev,
 	struct net_device *ndev = pci_get_drvdata(pdev);
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
+	netif_device_detach(ndev);
+
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	if (netif_running(ndev))
 		ql_adapter_down(qdev);
 
