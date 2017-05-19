From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/12] netfilter: ctnetlink: Make some parameters integer to avoid enum mismatch
Date: Fri, 19 May 2017 10:33:43 +0200
Message-ID: <1495182833-2272-3-git-send-email-pablo@netfilter.org>
References: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43950 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751948AbdESIeT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 04:34:19 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 2A7B41DA0A4
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1B0E3D1D81
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:11 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5F7CCFF2FA
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 10:34:08 +0200 (CEST)
In-Reply-To: <1495182833-2272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Kaehlcke <mka@chromium.org>

Not all parameters passed to ctnetlink_parse_tuple() and
ctnetlink_exp_dump_tuple() match the enum type in the signatures of these
functions. Since this is intended change the argument type of to be an
unsigned integer value.

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index dcf561b5c97a..fa752626029e 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1007,9 +1007,8 @@ static const struct nla_policy tuple_nla_policy[CTA_TUPLE_MAX+1] = {
 
 static int
 ctnetlink_parse_tuple(const struct nlattr * const cda[],
-		      struct nf_conntrack_tuple *tuple,
-		      enum ctattr_type type, u_int8_t l3num,
-		      struct nf_conntrack_zone *zone)
+		      struct nf_conntrack_tuple *tuple, u32 type,
+		      u_int8_t l3num, struct nf_conntrack_zone *zone)
 {
 	struct nlattr *tb[CTA_TUPLE_MAX+1];
 	int err;
@@ -2447,7 +2446,7 @@ static struct nfnl_ct_hook ctnetlink_glue_hook = {
 
 static int ctnetlink_exp_dump_tuple(struct sk_buff *skb,
 				    const struct nf_conntrack_tuple *tuple,
-				    enum ctattr_expect type)
+				    u32 type)
 {
 	struct nlattr *nest_parms;
 
-- 
2.1.4
