From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] igb: Use Intel OUI for VF MAC addresses
Date: Thu, 10 Sep 2009 18:48:27 -0700
Message-ID: <20090911014757.19631.66570.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:38762
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751975AbZIKBsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 21:48:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gregory Rose <gregory.v.rose@intel.com>

This patch changes the default VF MAC address generation to use an Intel
Organizational Unit Identifier (OUI), instead of a fully randomized
Ethernet address.  This is to help prevent accidental MAC address
collisions.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
---

 drivers/net/igb/igb.h      |    1 +
 drivers/net/igb/igb_main.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 7126fea..463d178 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -65,6 +65,7 @@ struct igb_adapter;
 #define IGB_MAX_VF_MC_ENTRIES              30
 #define IGB_MAX_VF_FUNCTIONS               8
 #define IGB_MAX_VFTA_ENTRIES               128
+#define OUI_LEN                            3
 
 struct vf_data_storage {
 	unsigned char vf_mac_addresses[ETH_ALEN];
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 943186b..290555c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1315,6 +1315,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		unsigned int num_vfs = (max_vfs > 7) ? 7 : max_vfs;
 		int i;
 		unsigned char mac_addr[ETH_ALEN];
+		unsigned char oui[OUI_LEN] = {0x02, 0xAA, 0x00};
 
 		if (num_vfs) {
 			adapter->vf_data = kcalloc(num_vfs,
@@ -1335,6 +1336,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 					     i < adapter->vfs_allocated_count;
 					     i++) {
 						random_ether_addr(mac_addr);
+						memcpy(mac_addr, oui, OUI_LEN);
 						igb_set_vf_mac(adapter, i,
 						               mac_addr);
 					}

