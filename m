From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 5/5] IPVS: Remove ip_vs_sync_cleanup from section __exit
Date: Tue,  1 Feb 2011 21:07:48 +1100
Message-ID: <1296554868-17002-6-git-send-email-horms@verge.net.au>
References: <1296554868-17002-1-git-send-email-horms@verge.net.au>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Hans Schillstrom <hans@schillstrom.com>,
	Patrick McHardy <kaber@trash.net>,
	Simon Horman <horms@verge.net.au>
To: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44292 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944Ab1BAKID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 05:08:03 -0500
In-Reply-To: <1296554868-17002-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_vs_sync_cleanup() may be called from ip_vs_init() on error
and thus needs to be accesible from section __init

Reporte-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index d5a6e64..2a2a836 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1686,7 +1686,7 @@ int __init ip_vs_sync_init(void)
 	return register_pernet_subsys(&ipvs_sync_ops);
 }
 
-void __exit ip_vs_sync_cleanup(void)
+void ip_vs_sync_cleanup(void)
 {
 	unregister_pernet_subsys(&ipvs_sync_ops);
 }
-- 
1.7.2.3

