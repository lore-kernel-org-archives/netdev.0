From: Nick Bowler <nbowler@elliptictech.com>
Subject: [PATCH] ah: Don't return NET_XMIT_DROP on input.
Date: Thu, 10 Nov 2011 14:01:27 -0500
Message-ID: <1320951687-21491-1-git-send-email-nbowler@elliptictech.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the ahash driver returns -EBUSY, AH4/6 input functions return
NET_XMIT_DROP, presumably copied from the output code path.  But
returning transmit codes on input doesn't make a lot of sense.
Since NET_XMIT_DROP is a positive int, this gets interpreted as
the next header type (i.e., success).  As that can only end badly,
remove the check.

Signed-off-by: Nick Bowler <nbowler@elliptictech.com>
---
This appears to be another longstanding issue (since the initial ahash
conversion circa 2.6.33), but there doesn't seem to be many ahash
drivers in the tree that can possibly trigger it.  Furthermore, most
if not all of these drivers require special hardware.

 net/ipv4/ah4.c |    2 --
 net/ipv6/ah6.c |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index c7056b2..36d1440 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -369,8 +369,6 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 		if (err == -EINPROGRESS)
 			goto out;
 
-		if (err == -EBUSY)
-			err = NET_XMIT_DROP;
 		goto out_free;
 	}
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index eb71dbc..0873a21 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -581,8 +581,6 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		if (err == -EINPROGRESS)
 			goto out;
 
-		if (err == -EBUSY)
-			err = NET_XMIT_DROP;
 		goto out_free;
 	}
 
-- 
1.7.3.4
