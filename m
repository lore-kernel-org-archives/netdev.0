From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 19/24] IVPS: Disable sync daemon for IPv6 connections
Date: Tue,  2 Sep 2008 15:55:50 +0200
Message-ID: <1220363755-9854-20-git-send-email-juliusv@google.com>
References: <1220363755-9854-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com,
	Julius Volz <juliusv@google.com>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:20300 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbYIBN4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 09:56:23 -0400
In-Reply-To: <1220363755-9854-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable the sync daemon for IPv6 connections, works only with IPv4 for now.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 27bef1d..5a7a817 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1321,7 +1321,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	 * encorage the standby servers to update the connections timeout
 	 */
 	atomic_inc(&cp->in_pkts);
-	if ((ip_vs_sync_state & IP_VS_STATE_MASTER) &&
+	if (af == AF_INET &&
+	    (ip_vs_sync_state & IP_VS_STATE_MASTER) &&
 	    (((cp->protocol != IPPROTO_TCP ||
 	       cp->state == IP_VS_TCP_S_ESTABLISHED) &&
 	      (atomic_read(&cp->in_pkts) % sysctl_ip_vs_sync_threshold[1]
-- 
1.5.4.5

