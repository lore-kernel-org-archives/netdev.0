From: Julius Volz <juliusv@google.com>
Subject: [PATCHv2 RFC 19/25] IVPS: Disable sync daemon for IPv6 connections
Date: Mon,  1 Sep 2008 14:56:16 +0200
Message-ID: <1220273782-19901-20-git-send-email-juliusv@google.com>
References: <1220273782-19901-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com,
	Julius Volz <juliusv@google.com>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:24580 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbYIAM5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 08:57:21 -0400
In-Reply-To: <1220273782-19901-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable the sync daemon for IPv6 connections, works only with IPv4 for now.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 2725b93..141454d 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1318,7 +1318,8 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
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

