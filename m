From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] geneve: Fix IPv6 xmit stats update.
Date: Mon,  7 Dec 2015 19:17:30 -0800
Message-ID: <1449544650-6112-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35414 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296AbbLHDRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 22:17:38 -0500
Received: by pacej9 with SMTP id ej9so4429101pac.2
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 19:17:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call to iptunnel_xmit_stats() is not required after udp-tunnel6-xmit.
By calling iptunnel_xmit_stats() results in incorrect device stats.
Following patch drops this call.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/geneve.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index de5c30c..c2b79f5 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -967,8 +967,6 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
 				   &fl6.saddr, &fl6.daddr, prio, ttl,
 				   sport, geneve->dst_port, !udp_csum);
-
-	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return NETDEV_TX_OK;
 
 tx_error:
-- 
1.7.1
