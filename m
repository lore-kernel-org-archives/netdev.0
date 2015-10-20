From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netfilter: xt_TEE: fix NULL dereference
Date: Mon, 19 Oct 2015 18:02:01 -0700
Message-ID: <1445302921.30896.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36496 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbbJTBCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 21:02:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

iptables -I INPUT ... -j TEE --gateway 10.1.2.3

<crash> because --oif was not specified

tee_tg_check() sets ->priv pointer to NULL in this case.

Fixes: bbde9fc1824a ("netfilter: factor out packet duplication for IPv4/IPv6")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/xt_TEE.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index fd980aa7715d..c5fdea18a9af 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -31,8 +31,9 @@ static unsigned int
 tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info = par->targinfo;
+	int oif = info->priv ? info->priv->oif : 0;
 
-	nf_dup_ipv4(skb, par->hooknum, &info->gw.in, info->priv->oif);
+	nf_dup_ipv4(skb, par->hooknum, &info->gw.in, oif);
 
 	return XT_CONTINUE;
 }
@@ -42,8 +43,9 @@ static unsigned int
 tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info = par->targinfo;
+	int oif = info->priv ? info->priv->oif : 0;
 
-	nf_dup_ipv6(skb, par->hooknum, &info->gw.in6, info->priv->oif);
+	nf_dup_ipv6(skb, par->hooknum, &info->gw.in6, oif);
 
 	return XT_CONTINUE;
 }
