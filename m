From: Andreas Bombe <aeb@debian.org>
Subject: [PATCH] ARCNET: Limit com20020 PCI ID matches for SOHARD cards
Date: Wed, 12 May 2010 02:49:06 +0200
Message-ID: <20100512004852.GA25845@amos.infernal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from infernal.debian.net ([87.230.26.131]:42608 "EHLO
	infernal.debian.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674Ab0ELB3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 21:29:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SH SOHARD ARCNET cards are implemented using generic PLX Technology
PCI<->IOBus bridges. Subvendor and subdevice IDs were not specified,
causing the driver to attach to any such bridge and likely crash the
system by attempting to initialize an unrelated device.

Fix by specifying subvendor and subdevice according to the values found
in the PCI-ID Repository at http://pci-ids.ucw.cz/ .

Cc: stable@kernel.org
Signed-off-by: Andreas Bombe <aeb@debian.org>
---

Compile tested only. This bug caused a new machine to be unbootable with
Debian install media due to rebooting right after some arc%d: SOHARD log
messages appeared.  Current SUSE and Fedora boot, presumably because
there are no compiled ARCNET drivers.

I couldn't find any information on the other PLX device ID 10b5:2200.
Also, the PCI ID repository says 14ba:6000 should really be 14ba:0600.
I have no way to verify that.

 drivers/net/arcnet/com20020-pci.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 2c712af..48a1dbf 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -164,8 +164,8 @@ static DEFINE_PCI_DEVICE_TABLE(com20020pci_id_table) = {
 	{ 0x1571, 0xa204, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x1571, 0xa205, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x1571, 0xa206, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x10B5, 0x9030, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
-	{ 0x10B5, 0x9050, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
+	{ 0x10B5, 0x9030, 0x10B5,     0x2978,     0, 0, ARC_CAN_10MBIT },
+	{ 0x10B5, 0x9050, 0x10B5,     0x2273,     0, 0, ARC_CAN_10MBIT },
 	{ 0x14BA, 0x6000, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{ 0x10B5, 0x2200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, ARC_CAN_10MBIT },
 	{0,}
-- 
1.7.1

