From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/5] netfilter: xt_LOG: fix mark logging for IPv6 packets
Date: Wed, 29 May 2013 18:03:12 +0200
Message-ID: <1369843394-24251-5-git-send-email-pablo@netfilter.org>
References: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Michal Kube=C4=8Dek <mkubecek@suse.cz>

In dump_ipv6_packet(), the "recurse" parameter is zero only if
dumping contents of a packet embedded into an ICMPv6 error
message. Therefore we want to log packet mark if recurse is
non-zero, not when it is zero.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_LOG.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
index 491c7d8..5ab2484 100644
--- a/net/netfilter/xt_LOG.c
+++ b/net/netfilter/xt_LOG.c
@@ -737,7 +737,7 @@ static void dump_ipv6_packet(struct sbuff *m,
 		dump_sk_uid_gid(m, skb->sk);
=20
 	/* Max length: 16 "MARK=3D0xFFFFFFFF " */
-	if (!recurse && skb->mark)
+	if (recurse && skb->mark)
 		sb_add(m, "MARK=3D0x%x ", skb->mark);
 }
=20
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
