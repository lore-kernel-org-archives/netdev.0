From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 03/11] netxen: remove unnecessary setting of skb->dev
Date: Mon,  9 Jul 2012 17:09:27 -0700
Message-ID: <1341878975-10577-3-git-send-email-jdmason@kudzu.us>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org, Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56424 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938Ab2GJAJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:09:13 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so20018595pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:09:13 -0700 (PDT)
In-Reply-To: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->dev is being unnecessarily set by the driver on packet recieve.
eth_type_trans already sets skb->dev to the proper value and it is not
referenced anywhere else in the dirver, thus making its setting unnecessary.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
Cc: Sony Chacko <sony.chacko@qlogic.com>
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 8694124..b2c1b676 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1532,8 +1532,6 @@ static struct sk_buff *netxen_process_rxbuf(struct netxen_adapter *adapter,
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
 
-	skb->dev = adapter->netdev;
-
 	buffer->skb = NULL;
 no_skb:
 	buffer->state = NETXEN_BUFFER_FREE;
-- 
1.7.9.5
