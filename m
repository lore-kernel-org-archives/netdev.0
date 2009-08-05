From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [net-next-2.6 PATCH 9/9] vxge: return PCI_ERS_RESULT_DISCONNECT on permanent failure
Date: Tue, 4 Aug 2009 20:48:35 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77058E5B77@nekter>
References: <20090731191254.5470.99642.send-patch@aqua> <20090731191403.5470.68576.send-patch@aqua>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Anil Murthy" <Anil.Murthy@neterion.com>
To: "Dean Nelson" <dnelson@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:35638 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932354AbZHEAsf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 20:48:35 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090731191403.5470.68576.send-patch@aqua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Reviewed the patch for vxge driver. Please accept it.

Thanks,
~Siva
-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Dean Nelson
Sent: Saturday, August 01, 2009 12:44 AM
To: netdev@vger.kernel.org
Cc: Ramkrishna Vepa
Subject: [net-next-2.6 PATCH 9/9] vxge: return PCI_ERS_RESULT_DISCONNECT
on permanent failure

PCI drivers that implement the struct pci_error_handlers' error_detected
callback should return PCI_ERS_RESULT_DISCONNECT if the state passed in
is
pci_channel_io_perm_failure. This patch fixes the issue for vxge.

Signed-off-by: Dean Nelson <dnelson@redhat.com>

---

This patch has not been tested, since I don't have the hardware to test
it.
It is based on a few recent patches. See the following commits:

http://git.kernel.org/linus/c93b5a76d58656158d195a7df507ebc660010969
http://git.kernel.org/linus/eab633021c26025b34f36f79f0311d3d99f40ceb
http://git.kernel.org/linus/ef681ce1e8b3e63317cd724c200b2fd39286c005
http://git.kernel.org/linus/59ed6eecff4aa00c5c5d18ffd180acac108d596e
http://git.kernel.org/linus/3044b8d1ff8c05237652a692fb572a34e4d70146

 drivers/net/vxge/vxge-main.c   |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 7b5402b..335140d 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3956,6 +3956,9 @@ static pci_ers_result_t
vxge_io_error_detected(struct pci_dev *pdev,
 
 	netif_device_detach(netdev);
 
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	if (netif_running(netdev)) {
 		/* Bring down the card, while avoiding PCI I/O */
 		do_vxge_close(netdev, 0);
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
