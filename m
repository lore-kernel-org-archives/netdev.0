From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v4] netfilter: ipt_CLUSTERIP: remove "no conntrack!"
Date: Thu, 13 Jan 2011 14:38:35 +0100
Message-ID: <1294925915.3570.87.camel@edumazet-laptop>
References: <4D2E1A74.5080102@netfilter.org>
	 <1294917210.3570.48.camel@edumazet-laptop> <4D2EE09A.1010409@netfilter.org>
	 <1294918365.3570.56.camel@edumazet-laptop> <4D2EE80B.6010707@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D2EE80B.6010707@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 13 janvier 2011 =C3=A0 12:54 +0100, Pablo Neira Ayuso a =C3=A9=
crit :

> But printing this does not provide any useful information. The first
> packet that does not belong to the cluster node that has received the
> packet, or the first invalid packet, will trigger this.
>=20
> Moreover, this confuses users since they can do nothing if they recei=
ve
> this message.
>=20
> Moreover, this target should be supersedes by the cluster match, whic=
h
> has been there for quite some time (it's also more flexible).

Now you mentioned it, cluster match is not as flexible right now,
its hashing is on source_ip only.

Many people still use ipt_CLUSTERIP, and probably for couple of years.

This issue was raised several times, we should fix CLUSTERIP for good.

Thanks

[PATCH v4] netfilter: ipt_CLUSTERIP: remove "no conntrack!"

When a packet is meant to be handled by another node of the cluster,
silently drop it instead of flooding kernel log.

Note : INVALID packets are also dropped without notice.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_CLUSTERIP.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ip=
t_CLUSTERIP.c
index 1e26a48..403ca57 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -300,13 +300,8 @@ clusterip_tg(struct sk_buff *skb, const struct xt_=
action_param *par)
 	 * that the ->target() function isn't called after ->destroy() */
=20
 	ct =3D nf_ct_get(skb, &ctinfo);
-	if (ct =3D=3D NULL) {
-		pr_info("no conntrack!\n");
-			/* FIXME: need to drop invalid ones, since replies
-			 * to outgoing connections of other nodes will be
-			 * marked as INVALID */
+	if (ct =3D=3D NULL)
 		return NF_DROP;
-	}
=20
 	/* special case: ICMP error handling. conntrack distinguishes between
 	 * error messages (RELATED) and information requests (see below) */


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
