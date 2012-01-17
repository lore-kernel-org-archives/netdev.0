From: pablo@netfilter.org
Subject: [PATCH 1/4] netfilter: xt_hashlimit: fix unused variable warning if IPv6 disabled
Date: Tue, 17 Jan 2012 12:04:46 +0100
Message-ID: <1326798289-11592-2-git-send-email-pablo@netfilter.org>
References: <1326798289-11592-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32785 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753432Ab2AQLFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 06:05:10 -0500
In-Reply-To: <1326798289-11592-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stephen Rothwell <sfr@canb.auug.org.au>

=46ixes this warning when CONFIG_IP6_NF_IPTABLES is not enabled:

net/netfilter/xt_hashlimit.c: In function =E2=80=98hashlimit_init_dst=E2=
=80=99:
net/netfilter/xt_hashlimit.c:448:9: warning: unused variable =E2=80=98f=
rag_off=E2=80=99 [-Wunused-variable]

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_hashlimit.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.=
c
index 8e49921..d95f9c9 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -445,7 +445,6 @@ hashlimit_init_dst(const struct xt_hashlimit_htable=
 *hinfo,
 {
 	__be16 _ports[2], *ports;
 	u8 nexthdr;
-	__be16 frag_off;
 	int poff;
=20
 	memset(dst, 0, sizeof(*dst));
@@ -466,6 +465,9 @@ hashlimit_init_dst(const struct xt_hashlimit_htable=
 *hinfo,
 		break;
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	case NFPROTO_IPV6:
+	{
+		__be16 frag_off;
+
 		if (hinfo->cfg.mode & XT_HASHLIMIT_HASH_DIP) {
 			memcpy(&dst->ip6.dst, &ipv6_hdr(skb)->daddr,
 			       sizeof(dst->ip6.dst));
@@ -485,6 +487,7 @@ hashlimit_init_dst(const struct xt_hashlimit_htable=
 *hinfo,
 		if ((int)protoff < 0)
 			return -1;
 		break;
+	}
 #endif
 	default:
 		BUG();
--=20
1.7.7.3
