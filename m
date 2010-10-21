From: kaber@trash.net
Subject: [PATCH 37/72] IPVS: ip_vs_dbg_callid() is only needed for debugging
Date: Thu, 21 Oct 2010 17:19:24 +0200
Message-ID: <1287674399-31455-38-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59992 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921Ab0JUPUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:10 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

ip_vs_dbg_callid() and IP_VS_DEBUG_CALLID() are only needed
it CONFIG_IP_VS_DEBUG is defined.

This resolves the following build warning when CONFIG_IP_VS_DEBUG is
not defined.

net/netfilter/ipvs/ip_vs_pe_sip.c:11: warning: 'ip_vs_dbg_callid' defined but not used

Reported-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipvs/ip_vs_pe_sip.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_pe_sip.c b/net/netfilter/ipvs/ip_vs_pe_sip.c
index a0539f1..b8b4e96 100644
--- a/net/netfilter/ipvs/ip_vs_pe_sip.c
+++ b/net/netfilter/ipvs/ip_vs_pe_sip.c
@@ -8,6 +8,7 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter/nf_conntrack_sip.h>
 
+#ifdef CONFIG_IP_VS_DEBUG
 static const char *ip_vs_dbg_callid(char *buf, size_t buf_len,
 				    const char *callid, size_t callid_len,
 				    int *idx)
@@ -22,6 +23,7 @@ static const char *ip_vs_dbg_callid(char *buf, size_t buf_len,
 #define IP_VS_DEBUG_CALLID(callid, len)					\
 	ip_vs_dbg_callid(ip_vs_dbg_buf, sizeof(ip_vs_dbg_buf),		\
 			 callid, len, &ip_vs_dbg_idx)
+#endif
 
 static int get_callid(const char *dptr, unsigned int dataoff,
 		      unsigned int datalen,
-- 
1.7.1

