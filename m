From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v3 21/23] net/core: remove duplicate statements by do-while loop
Date: Mon,  4 Mar 2013 21:58:29 +0900
Message-ID: <1362401911-14074-22-git-send-email-akinobu.mita@gmail.com>
References: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:49928 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758119Ab3CDNAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 08:00:00 -0500
In-Reply-To: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicate statements by using do-while loop instead of while loop.

- A;
- while (e) {
+ do {
	A;
- }
+ } while (e);

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---

No change from v2

 net/core/pktgen.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 4582275..5c21742 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2396,18 +2396,15 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 				__be32 s;
 				if (pkt_dev->flags & F_IPDST_RND) {
 
-					t = prandom_u32() % (imx - imn) + imn;
-					s = htonl(t);
-
-					while (ipv4_is_loopback(s) ||
-					       ipv4_is_multicast(s) ||
-					       ipv4_is_lbcast(s) ||
-					       ipv4_is_zeronet(s) ||
-					       ipv4_is_local_multicast(s)) {
+					do {
 						t = prandom_u32() %
 							(imx - imn) + imn;
 						s = htonl(t);
-					}
+					} while (ipv4_is_loopback(s) ||
+						ipv4_is_multicast(s) ||
+						ipv4_is_lbcast(s) ||
+						ipv4_is_zeronet(s) ||
+						ipv4_is_local_multicast(s));
 					pkt_dev->cur_daddr = s;
 				} else {
 					t = ntohl(pkt_dev->cur_daddr);
-- 
1.8.1.2
