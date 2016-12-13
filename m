From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 16/27] nfnetlink/queue: use __vlan_hwaccel helpers
Date: Tue, 13 Dec 2016 01:12:38 +0100 (CET)
Message-ID: <c1d383668d98227a456f799bd294c3669a52b39e.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org> (supporter:NETFILTER ({IP
        ,IP6,ARP,EB,NF}TABLES)),
        Patrick McHardy <kaber@trash.net> (supporter:NETFILTER ({IP,IP6,ARP
        ,EB,NF}TABLES)),
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu> (supporter:NETFILTER
        ({IP,IP6,ARP,EB,NF}TABLES)),
        netfilter-devel@vger.kernel.org (open list:NETFILTER ({IP,IP6,ARP,EB
        ,NF}TABLES))
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50252 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932560AbcLMAMl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:41 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 net/netfilter/nfnetlink_queue.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index be7627b..f268bb9 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -1111,8 +1111,9 @@ static int nfqa_parse_bridge(struct nf_queue_entry *entry,
 		if (!tb[NFQA_VLAN_TCI] || !tb[NFQA_VLAN_PROTO])
 			return -EINVAL;
 
-		entry->skb->vlan_tci = ntohs(nla_get_be16(tb[NFQA_VLAN_TCI]));
-		entry->skb->vlan_proto = nla_get_be16(tb[NFQA_VLAN_PROTO]);
+		__vlan_hwaccel_put_tag(entry->skb,
+			nla_get_be16(tb[NFQA_VLAN_PROTO]),
+			ntohs(nla_get_be16(tb[NFQA_VLAN_TCI])));
 	}
 
 	if (nfqa[NFQA_L2HDR]) {
-- 
2.10.2
