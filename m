From: Dean Nelson <dnelson@redhat.com>
Subject: [net-next-2.6 PATCH 8/9] s2io: return PCI_ERS_RESULT_DISCONNECT on permanent failure
Date: Fri, 31 Jul 2009 15:13:56 -0400
Message-ID: <20090731191355.5470.9692.send-patch@aqua>
References: <20090731191254.5470.99642.send-patch@aqua>
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40856 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752862AbZGaTPC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2009 15:15:02 -0400
In-Reply-To: <20090731191254.5470.99642.send-patch@aqua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI drivers that implement the struct pci_error_handlers' error_detected
callback should return PCI_ERS_RESULT_DISCONNECT if the state passed in is
pci_channel_io_perm_failure. This patch fixes the issue for s2io.

Signed-off-by: Dean Nelson <dnelson@redhat.com>

---

This patch has not been tested, since I don't have the hardware to test it.
It is based on a few recent patches. See the following commits:

http://git.kernel.org/linus/c93b5a76d58656158d195a7df507ebc660010969
http://git.kernel.org/linus/eab633021c26025b34f36f79f0311d3d99f40ceb
http://git.kernel.org/linus/ef681ce1e8b3e63317cd724c200b2fd39286c005
http://git.kernel.org/linus/59ed6eecff4aa00c5c5d18ffd180acac108d596e
http://git.kernel.org/linus/3044b8d1ff8c05237652a692fb572a34e4d70146

 drivers/net/s2io.c             |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index d4df933..bd6d713 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -8636,6 +8636,9 @@ static pci_ers_result_t s2io_io_error_detected(struct pci_dev *pdev,
 
 	netif_device_detach(netdev);
 
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	if (netif_running(netdev)) {
 		/* Bring down the card, while avoiding PCI I/O */
 		do_s2io_card_down(sp, 0);
