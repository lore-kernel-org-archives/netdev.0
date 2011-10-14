From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 15/15] ehea: Remove unused tcp_end field in send WQ
Date: Fri, 14 Oct 2011 12:31:12 -0300
Message-ID: <1318606272-27647-16-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:51459 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755339Ab1JNPbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:53 -0400
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id p9EGqhZl010552
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:52:43 -0400
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFZQ3L2805768
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:35:27 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVen9008932
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:41 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

The tcp_end field is not actually used by the hardware, so there
is no need to set it.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    2 --
 drivers/net/ethernet/ibm/ehea/ehea_qmr.h  |    2 +-
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index bfd08b2..adb462d 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -2001,7 +2001,6 @@ static void xmit_common(struct sk_buff *skb, struct ehea_swqe *swqe)
 
 		swqe->tcp_offset = swqe->ip_end + 1 +
 				   offsetof(struct udphdr, check);
-		swqe->tcp_end = skb->len - 1;
 		break;
 
 	case IPPROTO_TCP:
@@ -2010,7 +2009,6 @@ static void xmit_common(struct sk_buff *skb, struct ehea_swqe *swqe)
 
 		swqe->tcp_offset = swqe->ip_end + 1 +
 				   offsetof(struct tcphdr, check);
-		swqe->tcp_end = skb->len - 1;
 		break;
 	}
 }
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_qmr.h b/drivers/net/ethernet/ibm/ehea/ehea_qmr.h
index fddff8e..337a47e 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_qmr.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea_qmr.h
@@ -107,7 +107,7 @@ struct ehea_swqe {
 	u8 immediate_data_length;
 	u8 tcp_offset;
 	u8 reserved2;
-	u16 tcp_end;
+	u16 reserved2b;
 	u8 wrap_tag;
 	u8 descriptors;		/* number of valid descriptors in WQE */
 	u16 reserved3;
-- 
1.7.4.4
