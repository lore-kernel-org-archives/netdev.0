From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/7] netfilter: ebt_ip6: fix source and destination matching
Date: Thu, 21 Nov 2013 10:05:28 +0100
Message-ID: <1385024728-4057-8-git-send-email-pablo@netfilter.org>
References: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Lu=C3=ADs Fernando Cornachioni Estrozi <lestrozi@uolinc.com>

This bug was introduced on commit 0898f99a2. This just recovers two
checks that existed before as suggested by Bart De Schuymer.

Signed-off-by: Lu=C3=ADs Fernando Cornachioni Estrozi <lestrozi@uolinc.=
com>
Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_ip6.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_=
ip6.c
index 99c8566..17fd5f2 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -48,10 +48,12 @@ ebt_ip6_mt(const struct sk_buff *skb, struct xt_act=
ion_param *par)
 	if (info->bitmask & EBT_IP6_TCLASS &&
 	   FWINV(info->tclass !=3D ipv6_get_dsfield(ih6), EBT_IP6_TCLASS))
 		return false;
-	if (FWINV(ipv6_masked_addr_cmp(&ih6->saddr, &info->smsk,
-				       &info->saddr), EBT_IP6_SOURCE) ||
+	if ((info->bitmask & EBT_IP6_SOURCE &&
+	    FWINV(ipv6_masked_addr_cmp(&ih6->saddr, &info->smsk,
+				       &info->saddr), EBT_IP6_SOURCE)) ||
+	    (info->bitmask & EBT_IP6_DEST &&
 	    FWINV(ipv6_masked_addr_cmp(&ih6->daddr, &info->dmsk,
-				       &info->daddr), EBT_IP6_DEST))
+				       &info->daddr), EBT_IP6_DEST)))
 		return false;
 	if (info->bitmask & EBT_IP6_PROTO) {
 		uint8_t nexthdr =3D ih6->nexthdr;
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
