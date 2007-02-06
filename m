From: akpm@linux-foundation.org
Subject: [patch 11/11] netfilter warning fix
Date: Mon, 05 Feb 2007 16:31:11 -0800
Message-ID: <200702060032.l160WErX004652@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	akpm@linux-foundation.org, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41478 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965140AbXBFAc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:32:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

"using smp_processor_id() in preemptible code"

Cc: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/net/netfilter/nf_conntrack.h |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff -puN include/net/netfilter/nf_conntrack.h~netfilter-warning-fix include/net/netfilter/nf_conntrack.h
--- a/include/net/netfilter/nf_conntrack.h~netfilter-warning-fix
+++ a/include/net/netfilter/nf_conntrack.h
@@ -254,7 +254,12 @@ extern atomic_t nf_conntrack_count;
 extern int nf_conntrack_max;
 
 DECLARE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
-#define NF_CT_STAT_INC(count) (__get_cpu_var(nf_conntrack_stat).count++)
+#define NF_CT_STAT_INC(count)						\
+	do {								\
+		preempt_disable();					\
+		__get_cpu_var(nf_conntrack_stat).count++;		\
+		preempt_enable();					\
+	} while (0);
 
 /* no helper, no nat */
 #define	NF_CT_F_BASIC	0
_
