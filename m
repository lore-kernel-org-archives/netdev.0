From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next 2/3] bnx2x: change FW GRO error message to WARN_ONCE
Date: Fri,  4 Dec 2015 17:22:35 +0100
Message-ID: <1449246156-13796-3-git-send-email-mschmidt@redhat.com>
References: <1449246156-13796-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534AbbLDQWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 11:22:41 -0500
In-Reply-To: <1449246156-13796-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's supposed to be impossible for TPA to give us anything else
than IPv4 or IPv6 here. But in case there is a way to reach this error
by some strange received frames, we don't want to flood the kernel log.
WARN_ONCE is better for this purpose.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 5b6c17c53d..f6634a5241 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -743,7 +743,7 @@ static void bnx2x_gro_receive(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			bnx2x_gro_csum(bp, skb, bnx2x_gro_ipv6_csum);
 			break;
 		default:
-			BNX2X_ERR("Error: FW GRO supports only IPv4/IPv6, not 0x%04x\n",
+			WARN_ONCE(1, "Error: FW GRO supports only IPv4/IPv6, not 0x%04x\n",
 				  be16_to_cpu(skb->protocol));
 		}
 	}
-- 
2.5.0
