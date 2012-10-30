From: pablo@netfilter.org
Subject: [PATCH 3/3] netfilter: nf_defrag_ipv6: solve section mismatch in nf_conntrack_reasm
Date: Tue, 30 Oct 2012 11:19:20 +0100
Message-ID: <1351592360-5686-4-git-send-email-pablo@netfilter.org>
References: <1351592360-5686-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58440 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932649Ab2J3KTk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 06:19:40 -0400
In-Reply-To: <1351592360-5686-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hein Tibosch <hein_tibosch@yahoo.es>

WARNING: net/ipv6/netfilter/nf_defrag_ipv6.o(.text+0xe0): Section mismatch in
reference from the function nf_ct_net_init() to the function
.init.text:nf_ct_frag6_sysctl_register()
The function nf_ct_net_init() references the function
__init nf_ct_frag6_sysctl_register().

In case nf_conntrack_ipv6 is compiled as a module, nf_ct_net_init could be
called after the init code and data are unloaded. Therefore remove the
"__net_init" annotation from nf_ct_frag6_sysctl_register().

Signed-off-by: Hein Tibosch <hein_tibosch@yahoo.es>
Acked-by: Cong Wang <amwang@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 18bd9bb..22c8ea9 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -85,7 +85,7 @@ static struct ctl_table nf_ct_frag6_sysctl_table[] = {
 	{ }
 };
 
-static int __net_init nf_ct_frag6_sysctl_register(struct net *net)
+static int nf_ct_frag6_sysctl_register(struct net *net)
 {
 	struct ctl_table *table;
 	struct ctl_table_header *hdr;
@@ -127,7 +127,7 @@ static void __net_exit nf_ct_frags6_sysctl_unregister(struct net *net)
 }
 
 #else
-static int __net_init nf_ct_frag6_sysctl_register(struct net *net)
+static int nf_ct_frag6_sysctl_register(struct net *net)
 {
 	return 0;
 }
-- 
1.7.10.4
