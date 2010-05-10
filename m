From: kaber@trash.net
Subject: [PATCH 04/84] netfilter: net/netfilter/ipvs/ip_vs_ftp.c: Remove use of NIPQUAD
Date: Mon, 10 May 2010 22:17:35 +0200
Message-ID: <1273522735-24672-5-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54503 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756572Ab0EJUS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:18:58 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

NIPQUAD has very few uses left.

Remove this use and make the code have the identical form of the only
other use of "%u,%u,%u,%u,%u,%u" in net/ipv4/netfilter/nf_nat_ftp.c

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipvs/ip_vs_ftp.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 73f38ea..9f63283 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -208,8 +208,14 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		 */
 		from.ip = n_cp->vaddr.ip;
 		port = n_cp->vport;
-		sprintf(buf, "%u,%u,%u,%u,%u,%u", NIPQUAD(from.ip),
-			(ntohs(port)>>8)&255, ntohs(port)&255);
+		snprintf(buf, sizeof(buf), "%u,%u,%u,%u,%u,%u",
+			 ((unsigned char *)&from.ip)[0],
+			 ((unsigned char *)&from.ip)[1],
+			 ((unsigned char *)&from.ip)[2],
+			 ((unsigned char *)&from.ip)[3],
+			 ntohs(port) >> 8,
+			 ntohs(port) & 0xFF);
+
 		buf_len = strlen(buf);
 
 		/*
-- 
1.7.0.4

