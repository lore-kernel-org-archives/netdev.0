From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 29/84] ipvs: Pass ipvs not net to ip_vs_genl_parse_service
Date: Sun, 20 Sep 2015 01:22:45 -0500
Message-ID: <1442730220-32458-29-git-send-email-ebiederm@xmission.com>
References: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	lvs-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59295 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755060AbbITGel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 02:34:41 -0400
In-Reply-To: <87h9mplifu.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 4ca8d64ab6f1..1e3fc8962627 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3034,12 +3034,11 @@ nla_put_failure:
 	return skb->len;
 }
 
-static int ip_vs_genl_parse_service(struct net *net,
+static int ip_vs_genl_parse_service(struct netns_ipvs *ipvs,
 				    struct ip_vs_service_user_kern *usvc,
 				    struct nlattr *nla, int full_entry,
 				    struct ip_vs_service **ret_svc)
 {
-	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
 	struct nlattr *nla_af, *nla_port, *nla_fwmark, *nla_protocol, *nla_addr;
 	struct ip_vs_service *svc;
@@ -3123,11 +3122,12 @@ static int ip_vs_genl_parse_service(struct net *net,
 static struct ip_vs_service *ip_vs_genl_find_service(struct net *net,
 						     struct nlattr *nla)
 {
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct ip_vs_service_user_kern usvc;
 	struct ip_vs_service *svc;
 	int ret;
 
-	ret = ip_vs_genl_parse_service(net, &usvc, nla, 0, &svc);
+	ret = ip_vs_genl_parse_service(ipvs, &usvc, nla, 0, &svc);
 	return ret ? ERR_PTR(ret) : svc;
 }
 
@@ -3538,7 +3538,7 @@ static int ip_vs_genl_set_cmd(struct sk_buff *skb, struct genl_info *info)
 	if (cmd == IPVS_CMD_NEW_SERVICE || cmd == IPVS_CMD_SET_SERVICE)
 		need_full_svc = 1;
 
-	ret = ip_vs_genl_parse_service(net, &usvc,
+	ret = ip_vs_genl_parse_service(ipvs, &usvc,
 				       info->attrs[IPVS_CMD_ATTR_SERVICE],
 				       need_full_svc, &svc);
 	if (ret)
-- 
2.2.1
