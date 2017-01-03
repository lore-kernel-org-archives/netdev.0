From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next v2 16/27] nfnetlink/queue: use __vlan_hwaccel helpers
Date: Tue,  3 Jan 2017 21:52:36 +0100 (CET)
Message-ID: <1649ca2ec98ec50fe9ebdcea8e58d9bee1a57199.1483475202.git.mirq-linux@rere.qmqm.pl>
References: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1483475202.git.mirq-linux@rere.qmqm.pl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 net/netfilter/nfnetlink_queue.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 3ee0b8a000a4..8c7923aac826 100644
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
2.11.0

