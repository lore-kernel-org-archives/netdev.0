From: Simon Horman <horms@verge.net.au>
Subject: [patch] IPVS: ip_vs_dbg_callid() is only needed for debugging
Date: Thu, 7 Oct 2010 10:23:25 +0900
Message-ID: <20101007012325.GA32392@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55414 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756371Ab0JGBXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 21:23:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_vs_dbg_callid() and IP_VS_DEBUG_CALLID() are only needed
it CONFIG_IP_VS_DEBUG is defined.

This resolves the following build warning when CONFIG_IP_VS_DEBUG is
not defined.

net/netfilter/ipvs/ip_vs_pe_sip.c:11: warning: 'ip_vs_dbg_callid' defined but not used

Reported-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: nf-next-2.6/net/netfilter/ipvs/ip_vs_pe_sip.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/ipvs/ip_vs_pe_sip.c	2010-10-07 10:17:54.000000000 +0900
+++ nf-next-2.6/net/netfilter/ipvs/ip_vs_pe_sip.c	2010-10-07 10:18:33.000000000 +0900
@@ -8,6 +8,7 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <linux/netfilter/nf_conntrack_sip.h>
 
+#ifdef CONFIG_IP_VS_DEBUG
 static const char *ip_vs_dbg_callid(char *buf, size_t buf_len,
 				    const char *callid, size_t callid_len,
 				    int *idx)
@@ -22,6 +23,7 @@ static const char *ip_vs_dbg_callid(char
 #define IP_VS_DEBUG_CALLID(callid, len)					\
 	ip_vs_dbg_callid(ip_vs_dbg_buf, sizeof(ip_vs_dbg_buf),		\
 			 callid, len, &ip_vs_dbg_idx)
+#endif
 
 static int get_callid(const char *dptr, unsigned int dataoff,
 		      unsigned int datalen,
