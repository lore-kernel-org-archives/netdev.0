From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 04/06]: ixgb: don't truncate VLAN TCI with VLAN stripping
Date: Mon, 07 Jul 2008 00:48:15 +0200
Message-ID: <48714BAF.304@trash.net>
References: <487148E0.5040407@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010907050309050504050001"
Cc: Jeff Garzik <jeff@garzik.org>, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	john.ronciak@intel.com
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42106 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756650AbYGFWyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:54:16 -0400
In-Reply-To: <487148E0.5040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010907050309050504050001
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> These patches fix all drivers supporting VLAN header stripping to
> pass the complete VLAN TCI to vlan_hwaccel_{rx,receive_skb} instead
> of just the VID. The upper three bits contain the priority and are
> used for ingress priority mappings.
>
> The e1000 patch is runtime tested, the others only compile tested.
>
>
>  drivers/net/e1000/e1000_main.c |   12 ++++--------
>  drivers/net/e1000e/netdev.c    |    3 +--
>  drivers/net/igb/igb_main.c     |    3 +--
>  drivers/net/ixgb/ixgb_main.c   |    6 ++----
>  drivers/net/starfire.c         |    2 +-
>  drivers/net/tehuti.c           |    2 +-
>  drivers/net/tehuti.h           |    1 +
>  7 files changed, 11 insertions(+), 18 deletions(-)
>
> Patrick McHardy (6):
>       e1000: don't truncate VLAN TCI with VLAN stripping
>       e1000e: don't truncate VLAN TCI with VLAN stripping
>       igb: don't truncate VLAN TCI with VLAN stripping
>       ixgb: don't truncate VLAN TCI with VLAN stripping
>       starfire: don't truncate VLAN TCI with VLAN stripping
>       tehuti: don't truncate VLAN TCI with VLAN stripping
>
>   


--------------010907050309050504050001
Content-Type: text/x-diff;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04.diff"

ixgb: don't truncate VLAN TCI with VLAN stripping

The vlan_hwaccel_{rx,receive_skb} functions expect the full TCI field
for priority mappings, don't truncate the upper 4 bits.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 92c22c36d1e18c443bbbe0097c005ebc94e82a4f
tree 55cbe321e6dde27e06e1cec6bc6a73ae8ab14608
parent 4295edfa0ab04aff6be3c396e58cb5033aa729bc
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:14 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 00:25:14 +0200

 drivers/net/ixgb/ixgb_main.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index cb8dadd..41f3adf 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -2045,16 +2045,14 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 #ifdef CONFIG_IXGB_NAPI
 		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special) &
-					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
+				le16_to_cpu(rx_desc->special));
 		} else {
 			netif_receive_skb(skb);
 		}
 #else /* CONFIG_IXGB_NAPI */
 		if(adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special) &
-					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
+				le16_to_cpu(rx_desc->special));
 		} else {
 			netif_rx(skb);
 		}


--------------010907050309050504050001--
