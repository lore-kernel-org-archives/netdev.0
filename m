From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] include/net/genetlink.h: Allow genlmsg_cancel to accept a
 NULL argument
Date: Fri, 28 Jan 2011 16:43:40 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1101281642080.8546@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul.moore@hp.com,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nlmsg_cancel can accept NULL as its second argument, so for similarity,
this patch extends genlmsg_cancel to be able to accept a NULL second
argument as well.

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 include/net/genetlink.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 8a64b81..b4c7c1c 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -195,7 +195,8 @@ static inline int genlmsg_end(struct sk_buff *skb, void *hdr)
  */
 static inline void genlmsg_cancel(struct sk_buff *skb, void *hdr)
 {
-	nlmsg_cancel(skb, hdr - GENL_HDRLEN - NLMSG_HDRLEN);
+	if (hdr)
+		nlmsg_cancel(skb, hdr - GENL_HDRLEN - NLMSG_HDRLEN);
 }
 
 /**
