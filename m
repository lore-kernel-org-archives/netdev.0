From: kaber@trash.net
Subject: [PATCH 2/2] IPVS: precedence bug in ip_vs_sync_switch_mode()
Date: Wed,  9 Feb 2011 15:33:47 +0100
Message-ID: <1297262027-26237-3-git-send-email-kaber@trash.net>
References: <1297262027-26237-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52822 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235Ab1BIOeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 09:34:08 -0500
In-Reply-To: <1297262027-26237-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>

'!' has higher precedence than '&'.  IP_VS_STATE_MASTER is 0x1 so
the original code is equivelent to if (!ipvs->sync_state) ...

Signed-off-by: Dan Carpenter <error27@gmail.com>
Signed-off-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_sync.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 2a2a836..d1b7298 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -392,7 +392,7 @@ void ip_vs_sync_switch_mode(struct net *net, int mode)
 {
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
-	if (!ipvs->sync_state & IP_VS_STATE_MASTER)
+	if (!(ipvs->sync_state & IP_VS_STATE_MASTER))
 		return;
 	if (mode == ipvs->sysctl_sync_ver || !ipvs->sync_buff)
 		return;
-- 
1.7.2.3

