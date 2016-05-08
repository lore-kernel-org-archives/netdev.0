From: Kangjie Lu <kangjielu@gmail.com>
Subject: [PATCH] fix a kernel infoleak in x25 module
Date: Sun,  8 May 2016 12:10:14 -0400
Message-ID: <1462723814-14732-1-git-send-email-kjlu@gatech.edu>
Cc: davem@davemloft.net, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	taesoo@gatech.edu, insu@gatech.edu, csong84@gatech.edu,
	Kangjie Lu <kjlu@gatech.edu>
To: andrew.hendry@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stack object "dte_facilities" is allocated in x25_rx_call_request(),
which is supposed to be initialized in x25_negotiate_facilities.
However, 5 fields (8 bytes in total) are not initialized. This
object is then copied to userland via copy_to_user, thus infoleak
occurs.

Signed-off-by: Kangjie Lu <kjlu@gatech.edu>
---
 net/x25/x25_facilities.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index 2844031..a1c30c6 100644
--- a/net/x25/x25_facilities.c
+++ b/net/x25/x25_facilities.c
@@ -278,6 +278,7 @@ int x25_negotiate_facilities(struct sk_buff *skb, struct sock *sk,
 
 	memset(&theirs, 0, sizeof(theirs));
 	memcpy(new, ours, sizeof(*new));
+	memset(dte, 0, sizeof(*dte));
 
 	len = x25_parse_facilities(skb, &theirs, dte, &x25->vc_facil_mask);
 	if (len < 0)
-- 
1.9.1
