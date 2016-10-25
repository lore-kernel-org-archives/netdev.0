From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: [PATCH] uapi: Fix userspace compilation of ip_tables.h/ip6_tables.h
 in C++ mode
Date: Tue, 25 Oct 2016 17:03:25 -0600
Message-ID: <20161025230325.GA14955@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The implicit cast from void * is not allowed for C++ compilers, and the
arithmetic on void * generates warnings if a C++ application tries to include
these UAPI headers.

$ g++ -c t.cc
ip_tables.h:221:24: warning: pointer of type 'void *' used in arithmetic
ip_tables.h:221:24: error: invalid conversion from 'void*' to 'xt_entry_target*'

Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
---
 include/uapi/linux/netfilter_ipv4/ip_tables.h  | 2 +-
 include/uapi/linux/netfilter_ipv6/ip6_tables.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/netfilter_ipv4/ip_tables.h b/include/uapi/linux/netfilter_ipv4/ip_tables.h
index d0da53d96d93..4682b18f3f44 100644
--- a/include/uapi/linux/netfilter_ipv4/ip_tables.h
+++ b/include/uapi/linux/netfilter_ipv4/ip_tables.h
@@ -221,7 +221,7 @@ struct ipt_get_entries {
 static __inline__ struct xt_entry_target *
 ipt_get_target(struct ipt_entry *e)
 {
-	return (void *)e + e->target_offset;
+	return (struct xt_entry_target *)((__u8 *)e + e->target_offset);
 }
 
 /*
diff --git a/include/uapi/linux/netfilter_ipv6/ip6_tables.h b/include/uapi/linux/netfilter_ipv6/ip6_tables.h
index d1b22653daf2..05e0631a6d12 100644
--- a/include/uapi/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/uapi/linux/netfilter_ipv6/ip6_tables.h
@@ -261,7 +261,7 @@ struct ip6t_get_entries {
 static __inline__ struct xt_entry_target *
 ip6t_get_target(struct ip6t_entry *e)
 {
-	return (void *)e + e->target_offset;
+	return (struct xt_entry_target *)((__u8 *)e + e->target_offset);
 }
 
 /*
-- 
2.1.4
