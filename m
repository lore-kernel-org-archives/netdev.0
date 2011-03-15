From: kaber@trash.net
Subject: [PATCH 05/37] ipvs: avoid lookup for fwmark 0
Date: Tue, 15 Mar 2011 20:43:45 +0100
Message-ID: <1300218257-26953-6-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>

 	Restore the previous behaviour to lookup for fwmark
service only when fwmark is non-null. This saves only CPU.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index c73b0c8..f0369d6 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -411,9 +411,11 @@ ip_vs_service_get(struct net *net, int af, __u32 fwmark, __u16 protocol,
 	/*
 	 *	Check the table hashed by fwmark first
 	 */
-	svc = __ip_vs_svc_fwm_find(net, af, fwmark);
-	if (fwmark && svc)
-		goto out;
+	if (fwmark) {
+		svc = __ip_vs_svc_fwm_find(net, af, fwmark);
+		if (svc)
+			goto out;
+	}
 
 	/*
 	 *	Check the table hashed by <protocol,addr,port>
-- 
1.7.2.3

