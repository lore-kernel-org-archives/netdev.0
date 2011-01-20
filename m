From: kaber@trash.net
Subject: [PATCH 6/7] netfilter: nf_conntrack: fix linker error with NF_CONNTRACK_TIMESTAMP=n
Date: Thu, 20 Jan 2011 21:22:45 +0100
Message-ID: <1295554966-5263-7-git-send-email-kaber@trash.net>
References: <1295554966-5263-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295554966-5263-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

net/built-in.o: In function `nf_conntrack_init_net':
net/netfilter/nf_conntrack_core.c:1521:
	undefined reference to `nf_conntrack_tstamp_init'
net/netfilter/nf_conntrack_core.c:1531:
	undefined reference to `nf_conntrack_tstamp_fini'

Add dummy inline functions for the =n case to fix this.

Reported-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack_timestamp.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_timestamp.h b/include/net/netfilter/nf_conntrack_timestamp.h
index f17dcb6..fc9c82b 100644
--- a/include/net/netfilter/nf_conntrack_timestamp.h
+++ b/include/net/netfilter/nf_conntrack_timestamp.h
@@ -47,7 +47,19 @@ static inline void nf_ct_set_tstamp(struct net *net, bool enable)
 	net->ct.sysctl_tstamp = enable;
 }
 
+#ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
 extern int nf_conntrack_tstamp_init(struct net *net);
 extern void nf_conntrack_tstamp_fini(struct net *net);
+#else
+static inline int nf_conntrack_tstamp_init(struct net *net)
+{
+	return 0;
+}
+
+static inline void nf_conntrack_tstamp_fini(struct net *net)
+{
+	return;
+}
+#endif /* CONFIG_NF_CONNTRACK_TIMESTAMP */
 
 #endif /* _NF_CONNTRACK_TSTAMP_H */
-- 
1.7.3.4

