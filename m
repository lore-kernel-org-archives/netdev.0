From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/23] netfilter: ctnetlink: restore inlining for netlink message size calculation
Date: Fri, 22 Apr 2016 15:39:53 +0200
Message-ID: <1461332394-3994-23-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45275 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968AbcDVNk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:26 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id EB1E483D07
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D505DA827A
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:24 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E79349D0F0
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:21 +0200 (CEST)
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calm down gcc warnings:

net/netfilter/nf_conntrack_netlink.c:529:15: warning: 'ctnetlink_proto_size' defined but not used [-Wunused-function]
 static size_t ctnetlink_proto_size(const struct nf_conn *ct)
               ^
net/netfilter/nf_conntrack_netlink.c:546:15: warning: 'ctnetlink_acct_size' defined but not used [-Wunused-function]
 static size_t ctnetlink_acct_size(const struct nf_conn *ct)
               ^
net/netfilter/nf_conntrack_netlink.c:556:12: warning: 'ctnetlink_secctx_size' defined but not used [-Wunused-function]
 static int ctnetlink_secctx_size(const struct nf_conn *ct)
            ^
net/netfilter/nf_conntrack_netlink.c:572:15: warning: 'ctnetlink_timestamp_size' defined but not used [-Wunused-function]
 static size_t ctnetlink_timestamp_size(const struct nf_conn *ct)
               ^

So gcc compiles them out when CONFIG_NF_CONNTRACK_EVENTS and
CONFIG_NETFILTER_NETLINK_GLUE_CT are not set.

Fixes: 4054ff45454a9a4 ("netfilter: ctnetlink: remove unnecessary inlining")
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Arnd Bergmann <arnd@arndb.de>
---
 net/netfilter/nf_conntrack_netlink.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index caa4efe..6cca30e 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -336,7 +336,7 @@ nla_put_failure:
 #endif
 
 #ifdef CONFIG_NF_CONNTRACK_LABELS
-static int ctnetlink_label_size(const struct nf_conn *ct)
+static inline int ctnetlink_label_size(const struct nf_conn *ct)
 {
 	struct nf_conn_labels *labels = nf_ct_labels_find(ct);
 
@@ -526,7 +526,7 @@ nla_put_failure:
 	return -1;
 }
 
-static size_t ctnetlink_proto_size(const struct nf_conn *ct)
+static inline size_t ctnetlink_proto_size(const struct nf_conn *ct)
 {
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
@@ -543,7 +543,7 @@ static size_t ctnetlink_proto_size(const struct nf_conn *ct)
 	return len;
 }
 
-static size_t ctnetlink_acct_size(const struct nf_conn *ct)
+static inline size_t ctnetlink_acct_size(const struct nf_conn *ct)
 {
 	if (!nf_ct_ext_exist(ct, NF_CT_EXT_ACCT))
 		return 0;
@@ -553,7 +553,7 @@ static size_t ctnetlink_acct_size(const struct nf_conn *ct)
 	       ;
 }
 
-static int ctnetlink_secctx_size(const struct nf_conn *ct)
+static inline int ctnetlink_secctx_size(const struct nf_conn *ct)
 {
 #ifdef CONFIG_NF_CONNTRACK_SECMARK
 	int len, ret;
@@ -569,7 +569,7 @@ static int ctnetlink_secctx_size(const struct nf_conn *ct)
 #endif
 }
 
-static size_t ctnetlink_timestamp_size(const struct nf_conn *ct)
+static inline size_t ctnetlink_timestamp_size(const struct nf_conn *ct)
 {
 #ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
 	if (!nf_ct_ext_exist(ct, NF_CT_EXT_TSTAMP))
-- 
2.1.4
