From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v2 24/26] net/core: remove duplicate statements by do-while loop
Date: Thu,  3 Jan 2013 21:19:20 +0900
Message-ID: <1357215562-6288-25-git-send-email-akinobu.mita@gmail.com>
References: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

No change from v1

 net/core/pktgen.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d23ec86..48a3a29 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2379,18 +2379,15 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
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
1.7.11.7
