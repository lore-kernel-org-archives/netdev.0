From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 06/15] ehea: Add vlan_features
Date: Fri, 14 Oct 2011 12:31:03 -0300
Message-ID: <1318606272-27647-7-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:39699 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933207Ab1JNPbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:45 -0400
Received: from /spool/local
	by br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 14 Oct 2011 12:31:43 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFUG2F2678870
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:30:16 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVWrH008644
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:33 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

We weren't enabling any VLAN features so we missed out on checksum
offload and TSO when using VLANs. Enable them.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 0cb3a9b..1321809 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3190,6 +3190,8 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
 		      | NETIF_F_RXCSUM;
+	dev->vlan_features = NETIF_F_SG | NETIF_F_TSO | NETIF_F_HIGHDMA |
+			NETIF_F_IP_CSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	if (use_lro)
-- 
1.7.4.4
