From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 07/10] netvsc: remove unnecessary cast of void pointer
Date: Wed,  9 Aug 2017 17:46:09 -0700
Message-ID: <20170810004612.22163-8-sthemmin@microsoft.com>
References: <20170810004612.22163-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36849 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752529AbdHJAqX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:46:23 -0400
Received: by mail-pf0-f170.google.com with SMTP id c28so34327672pfe.3
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 17:46:23 -0700 (PDT)
In-Reply-To: <20170810004612.22163-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assignment to a typed pointer is sufficient in C.
No cast is needed.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 3219d2e8918f..9f89de17b5fa 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -523,9 +523,9 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 
 		rndis_msg_size += NDIS_VLAN_PPI_SIZE;
 		ppi = init_ppi_data(rndis_msg, NDIS_VLAN_PPI_SIZE,
-					IEEE_8021Q_INFO);
-		vlan = (struct ndis_pkt_8021q_info *)((void *)ppi +
-						ppi->ppi_offset);
+				    IEEE_8021Q_INFO);
+
+		vlan = (void *)ppi + ppi->ppi_offset;
 		vlan->vlanid = skb->vlan_tci & VLAN_VID_MASK;
 		vlan->pri = (skb->vlan_tci & VLAN_PRIO_MASK) >>
 				VLAN_PRIO_SHIFT;
@@ -538,8 +538,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		ppi = init_ppi_data(rndis_msg, NDIS_LSO_PPI_SIZE,
 				    TCP_LARGESEND_PKTINFO);
 
-		lso_info = (struct ndis_tcp_lso_info *)((void *)ppi +
-							ppi->ppi_offset);
+		lso_info = (void *)ppi + ppi->ppi_offset;
 
 		lso_info->lso_v2_transmit.type = NDIS_TCP_LARGE_SEND_OFFLOAD_V2_TYPE;
 		if (skb->protocol == htons(ETH_P_IP)) {
-- 
2.11.0
