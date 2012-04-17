From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 01/12] netfilter: add struct netns_ct_proto to support netfilter namespace
Date: Tue, 17 Apr 2012 10:56:12 +0800
Message-ID: <1334631383-12326-2-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the struct netns_ct_proto is used to store ctl_table_header and sysctl vars.
because udp_conntrack and udplite_conntrack are used by netns_ct_proto,
so move the udp_conntrack and udplite_conntrack to the header file,

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/netfilter/nf_conntrack_udp.h     |   10 ++++++
 include/linux/netfilter/nf_conntrack_udplite.h |   10 ++++++
 include/net/netns/conntrack.h                  |   37 ++++++++++++++++++++++++
 3 files changed, 57 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/netfilter/nf_conntrack_udp.h
 create mode 100644 include/linux/netfilter/nf_conntrack_udplite.h

diff --git a/include/linux/netfilter/nf_conntrack_udp.h b/include/linux/netfilter/nf_conntrack_udp.h
new file mode 100644
index 0000000..02869fc
--- /dev/null
+++ b/include/linux/netfilter/nf_conntrack_udp.h
@@ -0,0 +1,10 @@
+#ifndef _NF_CONNTRACK_UDP_H
+#define _NF_CONNTRACK_UDP_H
+
+enum udp_conntrack {
+	UDP_CT_UNREPLIED,
+	UDP_CT_REPLIED,
+	UDP_CT_MAX
+};
+
+#endif /* _NF_CONNTRACK_UDP_H */
diff --git a/include/linux/netfilter/nf_conntrack_udplite.h b/include/linux/netfilter/nf_conntrack_udplite.h
new file mode 100644
index 0000000..62b90a2
--- /dev/null
+++ b/include/linux/netfilter/nf_conntrack_udplite.h
@@ -0,0 +1,10 @@
+#ifndef _NF_CONNTRACK_UDPLITE_H
+#define _NF_CONNTRACK_UDPLITE_H
+
+enum udplite_conntrack {
+	UDPLITE_CT_UNREPLIED,
+	UDPLITE_CT_REPLIED,
+	UDPLITE_CT_MAX
+};
+
+#endif /* _NF_CONNTRACK_UDPLITE_H */
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 7a911ec..5845665 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -4,10 +4,46 @@
 #include <linux/list.h>
 #include <linux/list_nulls.h>
 #include <linux/atomic.h>
+#include <linux/netfilter/nf_conntrack_tcp.h>
+#include <linux/netfilter/nf_conntrack_udp.h>
+#include <linux/netfilter/nf_conntrack_udplite.h>
+#include <linux/netfilter/nf_conntrack_sctp.h>
 
 struct ctl_table_header;
 struct nf_conntrack_ecache;
 
+struct netns_ct_proto {
+	unsigned int            sysctl_generic_timeout;
+	unsigned int		sysctl_tcp_timeouts[TCP_CONNTRACK_TIMEOUT_MAX];
+	unsigned int		sysctl_tcp_loose;
+	unsigned int		sysctl_tcp_be_liberal;
+	unsigned int		sysctl_tcp_max_retrans;
+	unsigned int		sysctl_udp_timeouts[UDP_CT_MAX];
+	unsigned int		sysctl_udplite_timeouts[UDPLITE_CT_MAX];
+	unsigned int		sysctl_sctp_timeouts[SCTP_CONNTRACK_MAX];
+	unsigned int		sysctl_icmp_timeout;
+	unsigned int		sysctl_icmpv6_timeout;
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header *generic_sysctl_header;
+	struct ctl_table_header *tcp_sysctl_header;
+	struct ctl_table_header *udp_sysctl_header;
+	struct ctl_table_header *udplite_sysctl_header;
+	struct ctl_table_header *sctp_sysctl_header;
+	struct ctl_table_header *icmp_sysctl_header;
+	struct ctl_table_header *icmpv6_sysctl_header;
+	unsigned int		tcp_table_users;
+	unsigned int		udp_table_users;
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT 
+	struct ctl_table_header *generic_compat_header;
+	struct ctl_table_header *tcp_compat_header;
+	struct ctl_table_header *udp_compat_header;
+	struct ctl_table_header *sctp_compat_header;
+	struct ctl_table_header *icmp_compat_header;
+	struct ctl_table_header *ipv4_compat_header;
+#endif
+#endif
+};
+
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
@@ -26,6 +62,7 @@ struct netns_ct {
 	int			sysctl_tstamp;
 	int			sysctl_checksum;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
+	struct netns_ct_proto	proto;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
-- 
1.7.7.6

