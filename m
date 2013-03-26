From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] pch_gbe: fix ip_summed checksum reporting on rx
Date: Tue, 26 Mar 2013 09:26:21 +0100
Message-ID: <1364286381-10031-1-git-send-email-vfalico@redhat.com>
Cc: richardcochran@gmail.com, tshimizu818@gmail.com,
	vfalico@redhat.com, andy.cress@us.kontron.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934019Ab3CZIZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 04:25:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->ip_summed should be CHECKSUM_UNNECESSARY when the driver reports that
checksums were correct and CHECKSUM_NONE in any other case. They're
currently placed vice versa, which breaks the forwarding scenario. Fix it
by placing them as described above.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 39ab4d0..73ce7dd 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1726,9 +1726,9 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 
 			skb->protocol = eth_type_trans(skb, netdev);
 			if (tcp_ip_status & PCH_GBE_RXD_ACC_STAT_TCPIPOK)
-				skb->ip_summed = CHECKSUM_NONE;
-			else
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			else
+				skb->ip_summed = CHECKSUM_NONE;
 
 			napi_gro_receive(&adapter->napi, skb);
 			(*work_done)++;
-- 
1.7.1
