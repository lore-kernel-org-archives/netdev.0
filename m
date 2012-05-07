From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH] net/bluetooth/bnep/core.c: use constant for ethertype
Date: Tue,  8 May 2012 00:09:35 +0200
Message-ID: <1336428575-28996-1-git-send-email-eldad@fogrefinery.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eldad Zack <eldad@fogrefinery.com>
To: Marcel Holtmann <marcel@holtmann.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dot1q ethertype number (0x8100) is embedded in the code, although
it is already defined in included headers.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/bluetooth/bnep/core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index a779ec7..4fab436 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -340,7 +340,7 @@ static inline int bnep_rx_frame(struct bnep_session *s, struct sk_buff *skb)
 	}
 
 	/* Strip 802.1p header */
-	if (ntohs(s->eh.h_proto) == 0x8100) {
+	if (ntohs(s->eh.h_proto) == ETH_P_8021Q) {
 		if (!skb_pull(skb, 4))
 			goto badframe;
 		s->eh.h_proto = get_unaligned((__be16 *) (skb->data - 2));
-- 
1.7.10
