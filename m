From: Anton Protopopov <a.s.protopopov@gmail.com>
Subject: [PATCH] net: caif: fix erroneous return value
Date: Wed, 17 Feb 2016 10:54:13 -0500
Message-ID: <1455724453-10064-1-git-send-email-a.s.protopopov@gmail.com>
Cc: Anton Protopopov <a.s.protopopov@gmail.com>
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cfrfml_receive() function might return positive value EPROTO

Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>
---
 net/caif/cfrfml.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 61d7617..b82440e 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -159,7 +159,7 @@ static int cfrfml_receive(struct cflayer *layr, struct cfpkt *pkt)
 		tmppkt = NULL;
 
 		/* Verify that length is correct */
-		err = EPROTO;
+		err = -EPROTO;
 		if (rfml->pdu_size != cfpkt_getlen(pkt) - RFM_HEAD_SIZE + 1)
 			goto out;
 	}
-- 
2.6.5
