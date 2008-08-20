From: Julius Volz <juliusv@google.com>
Subject: [PATCH RFC 14/24] IPVS: Turn off FTP application helper for IPv6
Date: Wed, 20 Aug 2008 18:15:21 +0200
Message-ID: <1219248931-15064-15-git-send-email-juliusv@google.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, kaber@trash.net, vbusam@google.com,
	Julius Volz <juliusv@google.com>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:51606 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251AbYHTQQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 12:16:06 -0400
In-Reply-To: <1219248931-15064-1-git-send-email-juliusv@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Immediately return from FTP application helper and do nothing when dealing
with IPv6 packets. IPv6 is not supported by this helper yet.

Signed-off-by: Julius Volz <juliusv@google.com>

 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
index c1c758e..b4c7491 100644
--- a/net/ipv4/ipvs/ip_vs_ftp.c
+++ b/net/ipv4/ipvs/ip_vs_ftp.c
@@ -147,6 +147,14 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
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
@@ -247,6 +255,14 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
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
1.5.4.5

