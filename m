From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 4/6] qlcnic: fix race in skb->len access.
Date: Thu, 14 Jul 2011 06:16:53 -0700
Message-ID: <1310649415-14787-5-git-send-email-amit.salecha@qlogic.com>
References: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:44910 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754937Ab1GNNZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 09:25:49 -0400
In-Reply-To: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

As soon as skb is given to hardware, TX completion can free skb under us.
Therefore, we should update dev stats before kicking the device.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 916570d..006a693 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2290,11 +2290,11 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (adapter->mac_learn)
 		qlcnic_send_filter(adapter, tx_ring, first_desc, skb);
 
-	qlcnic_update_cmd_producer(adapter, tx_ring);
-
 	adapter->stats.txbytes += skb->len;
 	adapter->stats.xmitcalled++;
 
+	qlcnic_update_cmd_producer(adapter, tx_ring);
+
 	return NETDEV_TX_OK;
 
 unwind_buff:
-- 
1.7.3.3

