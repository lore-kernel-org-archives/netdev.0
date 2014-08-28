From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Subject: [PATCH net-next 2/2] bnx2x: fix tunneled GSO over IPv6
Date: Thu, 28 Aug 2014 16:54:24 +0300
Message-ID: <1409234064-20619-2-git-send-email-Dmitry.Kravkov@qlogic.com>
References: <1409234064-20619-1-git-send-email-Dmitry.Kravkov@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dan.carpenter@oracle.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:20819 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbaH1Nyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 09:54:47 -0400
In-Reply-To: <1409234064-20619-1-git-send-email-Dmitry.Kravkov@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set correct bit for packed description.

Introduced in e42780b66aab88d3a82b6087bcd6095b90eecde7
    bnx2x: Utilize FW 7.10.51

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a54ac45..2a08613 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3651,7 +3651,7 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
 		pbd2->fw_ip_hdr_to_payload_w =
 			hlen_w - ((sizeof(struct ipv6hdr)) >> 1);
 		pbd_e2->data.tunnel_data.flags |=
-			1 /*IPv6*/ << ETH_TUNNEL_DATA_IP_HDR_TYPE_OUTER;
+			ETH_TUNNEL_DATA_IP_HDR_TYPE_OUTER;
 	}
 
 	pbd2->tcp_send_seq = bswab32(inner_tcp_hdr(skb)->seq);
-- 
1.9.3
