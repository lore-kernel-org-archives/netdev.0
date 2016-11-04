From: =?UTF-8?q?Asbj=C3=B8rn=20Sloth=20T=C3=B8nnesen?=
        <asbjorn@asbjorn.st>
Subject: [PATCH iproute2 3/7] l2tp: fix integers with too few significant bits
Date: Fri,  4 Nov 2016 23:11:07 +0000
Message-ID: <20161104231111.14677-3-asbjorn@asbjorn.st>
References: <20161104231111.14677-1-asbjorn@asbjorn.st>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:58275 "EHLO mail.asbjorn.biz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752794AbcKDXLt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 19:11:49 -0400
In-Reply-To: <20161104231111.14677-1-asbjorn@asbjorn.st>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp6_csum{,_tx,_rx}, tunnel and session are the only ones
currently used.

recv_seq, send_seq, lns_mode and data_seq are partially
implemented in a useless way.

Signed-off-by: Asbjørn Sloth Tønnesen <asbjorn@asbjorn.st>
---
 ip/ipl2tp.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index d3338ac..2e0e9c7 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -56,15 +56,15 @@ struct l2tp_parm {
 
 	uint16_t pw_type;
 	uint16_t mtu;
-	int udp6_csum_tx:1;
-	int udp6_csum_rx:1;
-	int udp_csum:1;
-	int recv_seq:1;
-	int send_seq:1;
-	int lns_mode:1;
-	int data_seq:2;
-	int tunnel:1;
-	int session:1;
+	unsigned int udp6_csum_tx:1;
+	unsigned int udp6_csum_rx:1;
+	unsigned int udp_csum:1;
+	unsigned int recv_seq:1;
+	unsigned int send_seq:1;
+	unsigned int lns_mode:1;
+	unsigned int data_seq:2;
+	unsigned int tunnel:1;
+	unsigned int session:1;
 	int reorder_timeout;
 	const char *ifname;
 	uint8_t l2spec_type;
-- 
2.10.1
