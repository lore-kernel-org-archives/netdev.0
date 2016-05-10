From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next] gtp: reload GTPv1 header after pskb_may_pull()
Date: Tue, 10 May 2016 21:33:38 +0200
Message-ID: <1462908818-6104-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38224 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693AbcEJTdu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 15:33:50 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 27903C124D
	for <netdev@vger.kernel.org>; Tue, 10 May 2016 21:33:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 14E472687CD
	for <netdev@vger.kernel.org>; Tue, 10 May 2016 21:33:47 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E85A02687C8
	for <netdev@vger.kernel.org>; Tue, 10 May 2016 21:33:44 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The GTPv1 header flags indicate the presence of optional extensions
after this header. Refresh the pointer to the GTPv1 header as skb->head
might have be reallocated via pskb_may_pull().

Fixes: 459aa660eb1d ("gtp: add initial driver for datapath of GPRS Tunneling Protocol (GTP-U)")
Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/gtp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 8ce1104..f7caf1e 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -253,6 +253,8 @@ static int gtp1u_udp_encap_recv(struct gtp_dev *gtp, struct sk_buff *skb,
 	if (!pskb_may_pull(skb, hdrlen))
 		return -1;
 
+	gtp1 = (struct gtp1_header *)(skb->data + sizeof(struct udphdr));
+
 	rcu_read_lock();
 	pctx = gtp1_pdp_find(gtp, ntohl(gtp1->tid));
 	if (!pctx) {
-- 
2.1.4
