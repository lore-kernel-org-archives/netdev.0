From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 03/06]: igb: don't truncate VLAN TCI with VLAN stripping
Date: Mon, 07 Jul 2008 00:48:13 +0200
Message-ID: <48714BAD.3020501@trash.net>
References: <487148E0.5040407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080702000907010604070508"
Cc: Jeff Garzik <jeff@garzik.org>, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	john.ronciak@intel.com
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42102 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756301AbYGFWyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:54:14 -0400
In-Reply-To: <487148E0.5040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080702000907010604070508
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit




--------------080702000907010604070508
Content-Type: text/x-diff;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

igb: don't truncate VLAN TCI with VLAN stripping

The vlan_hwaccel_{rx,receive_skb} functions expect the full TCI field
for priority mappings, don't truncate the upper 4 bits.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4295edfa0ab04aff6be3c396e58cb5033aa729bc
tree 0cc631675d1eb2adc9a34b9d0cba32a124b9254d
parent aef20146b65b227a9eba0fa84bd1bd36fbdd7805
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:13 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:13 +0200

 drivers/net/igb/igb_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7bc6fae..afd4ce3 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3391,8 +3391,7 @@ static void igb_receive_skb(struct igb_adapter *adapter, u8 status, __le16 vlan,
 {
 	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
 		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-					 le16_to_cpu(vlan) &
-					 E1000_RXD_SPC_VLAN_MASK);
+					 le16_to_cpu(vlan));
 	else
 		netif_receive_skb(skb);
 }


--------------080702000907010604070508--
