From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH v3 net-next 2/8] geneve: Use skb mark and protocol to lookup route.
Date: Mon, 24 Aug 2015 10:43:09 -0700
Message-ID: <1440438195-5695-3-git-send-email-pshelar@nicira.com>
References: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33342 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065AbbHXRnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 13:43:24 -0400
Received: by pacti10 with SMTP id ti10so28800842pac.0
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 10:43:23 -0700 (PDT)
In-Reply-To: <1440438195-5695-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On packet transmit path geneve need to lookup route. Following
patch improves route lookup using more parameters.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Reviewed-by: Jesse Gross <jesse@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/geneve.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 95e9da0..3c5b2b1 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -202,6 +202,9 @@ static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.flowi4_tos = RT_TOS(tos);
 	fl4.daddr = geneve->remote.sin_addr.s_addr;
+	fl4.flowi4_mark = skb->mark;
+	fl4.flowi4_proto = IPPROTO_UDP;
+
 	rt = ip_route_output_key(geneve->net, &fl4);
 	if (IS_ERR(rt)) {
 		netdev_dbg(dev, "no route to %pI4\n", &fl4.daddr);
-- 
1.7.1
