From: kaber@trash.net
Subject: [PATCH 23/37] IPVS: ip_vs_todrop() becomes a noop when CONFIG_SYSCTL is undefined
Date: Tue, 15 Mar 2011 20:44:03 +0100
Message-ID: <1300218257-26953-24-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49430 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758498Ab1COToc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:32 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 687ef18..77ebece 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1253,6 +1253,7 @@ extern int ip_vs_icmp_xmit_v6
  int offset);
 #endif
 
+#ifdef CONFIG_SYSCTL
 /*
  *	This is a simple mechanism to ignore packets when
  *	we are loaded. Just set ip_vs_drop_rate to 'n' and
@@ -1268,6 +1269,9 @@ static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
 	ipvs->drop_counter = ipvs->drop_rate;
 	return 1;
 }
+#else
+static inline int ip_vs_todrop(struct netns_ipvs *ipvs) { return 0; }
+#endif
 
 /*
  *      ip_vs_fwd_tag returns the forwarding tag of the connection
-- 
1.7.2.3

