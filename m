From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 10/13] Export UDP socket lookup function
Date: Mon, 05 Mar 2007 16:46:32 +0100
Message-ID: <20070305154631.3471.85876.stgit@nienna.balabit>
References: <20070305154451.3471.18396.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:3020 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933543AbXCEPqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 10:46:33 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 5F6DD294023
	for <netdev@vger.kernel.org>; Mon,  5 Mar 2007 16:46:32 +0100 (CET)
In-Reply-To: <20070305154451.3471.18396.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The iptables tproxy code has to be able to do UDP socket hash lookups,
so we have to provide an exported lookup function for this purpose.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/net/udp.h |    4 ++++
 net/ipv4/udp.c    |    8 ++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 1b921fa..ea5aa31 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -141,6 +141,10 @@ extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
 				   char __user *optval, int optlen,
 				   int (*push_pending_frames)(struct sock *));
 
+extern struct sock *udp4_lib_lookup(__be32 saddr, __be16 sport,
+				    __be32 daddr, __be16 dport,
+				    int dif);
+
 DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1d15edc..52695a6 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -285,6 +285,14 @@ static struct sock *__udp4_lib_lookup(__be32 saddr, __be16 sport,
 	return result;
 }
 
+struct sock *udp4_lib_lookup(__be32 saddr, __be16 sport,
+			     __be32 daddr, __be16 dport,
+			     int dif)
+{
+	return __udp4_lib_lookup(saddr, sport, daddr, dport, dif, udp_hash);
+}
+EXPORT_SYMBOL_GPL(udp4_lib_lookup);
+
 static inline struct sock *udp_v4_mcast_next(struct sock *sk,
 					     __be16 loc_port, __be32 loc_addr,
 					     __be16 rmt_port, __be32 rmt_addr,

