From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 7/7] l2tp: show tunnel: expose UDP checksum state
Date: Fri,  4 Nov 2016 23:11:11 +0000
Message-ID: <20161104231111.14677-7-asbjorn@asbjorn.st>
References: <20161104231111.14677-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:44180 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751905AbcKDXLr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 19:11:47 -0400
In-Reply-To: <20161104231111.14677-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 ip/ipl2tp.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 8f3268d..27dc184 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -218,9 +218,24 @@ static void print_tunnel(const struct l2tp_data *data)
 	printf("  Peer tunnel %u\n",
 	       p->peer_tunnel_id);
 
-	if (p->encap == L2TP_ENCAPTYPE_UDP)
+	if (p->encap == L2TP_ENCAPTYPE_UDP) {
 		printf("  UDP source / dest ports: %hu/%hu\n",
 		       p->local_udp_port, p->peer_udp_port);
+
+		switch (p->local_ip.family) {
+		case AF_INET:
+			printf("  UDP checksum: %s\n",
+			       p->udp_csum ? "enabled" : "disabled");
+			break;
+		case AF_INET6:
+			printf("  UDP checksum: %s%s%s%s\n",
+			       p->udp6_csum_tx && p->udp6_csum_rx ? "enabled" : "",
+			       p->udp6_csum_tx && !p->udp6_csum_rx ? "tx" : "",
+			       !p->udp6_csum_tx && p->udp6_csum_rx ? "rx" : "",
+			       !p->udp6_csum_tx && !p->udp6_csum_rx ? "disabled" : "");
+			break;
+		}
+	}
 }
 
 static void print_session(struct l2tp_data *data)
-- 
2.10.1
