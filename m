From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH RFC]: e1000: allow VLAN devices to use TSO and CSUM offload
Date: Wed, 16 Jul 2008 12:05:15 +0200
Message-ID: <487DC7DB.70401@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090500080300080106090301"
To: Linux Netdev List <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50672 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224AbYGPKFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:05:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090500080300080106090301
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch changes e1000 to set vlan_features so TSO and CSUM
offload can be used by VLAN devices, similar as with the other
Intel drivers.

Only RFC because I don't know whether there is buggy hardware
that doesn't support this properly, but feel free to apply in
case there isn't.



--------------090500080300080106090301
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 9648c6ef22e4f6e14ed5b5d91d9809779bb520c7
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jul 16 11:45:09 2008 +0200

    e1000: allow VLAN devices to use TSO and CSUM offload
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f8df8bd..b6b3135 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1011,6 +1011,11 @@ e1000_probe(struct pci_dev *pdev,
 
 	netdev->features |= NETIF_F_LLTX;
 
+	netdev->vlan_features |= NETIF_F_TSO;
+	netdev->vlan_features |= NETIF_F_TSO6;
+	netdev->vlan_features |= NETIF_F_HW_CSUM;
+	netdev->vlan_features |= NETIF_F_SG;
+
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* initialize eeprom parameters */

--------------090500080300080106090301--
