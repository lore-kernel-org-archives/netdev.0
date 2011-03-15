From: kaber@trash.net
Subject: [PATCH 19/37] IPVS: Add sysctl_sync_ver()
Date: Tue, 15 Mar 2011 20:43:59 +0100
Message-ID: <1300218257-26953-20-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49429 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab1COToa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:30 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

In preparation for not including sysctl_sync_ver in
struct netns_ipvs when CONFIG_SYCTL is not defined.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 include/net/ip_vs.h             |   11 +++++++++++
 net/netfilter/ipvs/ip_vs_sync.c |    4 ++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 253736d..687ef18 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -911,6 +911,7 @@ struct netns_ipvs {
 
 #define DEFAULT_SYNC_THRESHOLD	3
 #define DEFAULT_SYNC_PERIOD	50
+#define DEFAULT_SYNC_VER	1
 
 #ifdef CONFIG_SYSCTL
 
@@ -924,6 +925,11 @@ static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
 	return ipvs->sysctl_sync_threshold[1];
 }
 
+static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
+{
+	return ipvs->sysctl_sync_ver;
+}
+
 #else
 
 static inline int sysctl_sync_threshold(struct netns_ipvs *ipvs)
@@ -936,6 +942,11 @@ static inline int sysctl_sync_period(struct netns_ipvs *ipvs)
 	return DEFAULT_SYNC_PERIOD;
 }
 
+static inline int sysctl_sync_ver(struct netns_ipvs *ipvs)
+{
+	return DEFAULT_SYNC_VER;
+}
+
 #endif
 
 /*
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index e84987f..3e7961e 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -394,7 +394,7 @@ void ip_vs_sync_switch_mode(struct net *net, int mode)
 
 	if (!(ipvs->sync_state & IP_VS_STATE_MASTER))
 		return;
-	if (mode == ipvs->sysctl_sync_ver || !ipvs->sync_buff)
+	if (mode == sysctl_sync_ver(ipvs) || !ipvs->sync_buff)
 		return;
 
 	spin_lock_bh(&ipvs->sync_buff_lock);
@@ -521,7 +521,7 @@ void ip_vs_sync_conn(struct net *net, struct ip_vs_conn *cp)
 	unsigned int len, pe_name_len, pad;
 
 	/* Handle old version of the protocol */
-	if (ipvs->sysctl_sync_ver == 0) {
+	if (sysctl_sync_ver(ipvs) == 0) {
 		ip_vs_sync_conn_v0(net, cp);
 		return;
 	}
-- 
1.7.2.3

