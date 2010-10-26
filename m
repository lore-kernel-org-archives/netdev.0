From: David Miller <davem@davemloft.net>
Subject: [PATCH] netfilter: Add missing CONFIG_SYSCTL checks in ipv6's
 nf_conntrack_reasm.c
Date: Tue, 26 Oct 2010 09:10:35 -0700 (PDT)
Message-ID: <20101026.091035.183042897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58468
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759959Ab0JZQKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 12:10:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

I just committed this to net-2.6, just FYI.

 net/ipv6/netfilter/nf_conntrack_reasm.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 489d71b..3a3f129 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -625,21 +625,24 @@ int nf_ct_frag6_init(void)
 	inet_frags_init_net(&nf_init_frags);
 	inet_frags_init(&nf_frags);
 
+#ifdef CONFIG_SYSCTL
 	nf_ct_frag6_sysctl_header = register_sysctl_paths(nf_net_netfilter_sysctl_path,
 							  nf_ct_frag6_sysctl_table);
 	if (!nf_ct_frag6_sysctl_header) {
 		inet_frags_fini(&nf_frags);
 		return -ENOMEM;
 	}
+#endif
 
 	return 0;
 }
 
 void nf_ct_frag6_cleanup(void)
 {
+#ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(nf_ct_frag6_sysctl_header);
 	nf_ct_frag6_sysctl_header = NULL;
-
+#endif
 	inet_frags_fini(&nf_frags);
 
 	nf_init_frags.low_thresh = 0;
-- 
1.7.3.2

