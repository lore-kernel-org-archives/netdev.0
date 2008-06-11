From: "Julius R. Volz" <juliusv@google.com>
Subject: [PATCH 13/26] IPVS: Turn off FTP application helper for IPv6.
Date: Wed, 11 Jun 2008 19:11:56 +0200
Message-ID: <1213204329-10973-14-git-send-email-juliusv@google.com>
References: <1213204329-10973-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, davem@davemloft.net, vbusam@google.com,
	"Julius R. Volz" <juliusv@google.com>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:14479 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbYFKRMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:12:34 -0400
In-Reply-To: <1213204329-10973-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Immediately return from FTP application helper and do nothing when dealing
with IPv6 packets. IPv6 is not supported by this helper yet.

Signed-off-by: Julius R. Volz <juliusv@google.com>

 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 6542fa9..6b02b5f 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -149,6 +149,14 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	unsigned buf_len;
 	int ret;
 
+#ifdef CONFIG_IP_VS_IPV6
+	/* This application helper doesn't work with IPv6 yet,
+	 * so turn this into a no-op for IPv6 packets
+	 */
+	if (cp->af == AF_INET6)
+		return 1;
+#endif
+
 	*diff = 0;
 
 	/* Only useful for established sessions */
@@ -249,6 +257,14 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	__be16 port;
 	struct ip_vs_conn *n_cp;
 
+#ifdef CONFIG_IP_VS_IPV6
+	/* This application helper doesn't work with IPv6 yet,
+	 * so turn this into a no-op for IPv6 packets
+	 */
+	if (cp->af == AF_INET6)
+		return 1;
+#endif
+
 	/* no diff required for incoming packets */
 	*diff = 0;
 
-- 
1.5.3.6

