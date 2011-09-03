From: kaber@trash.net
Subject: [PATCH 04/11] netlink: don't orphan skb in netlink_trim()
Date: Sat,  3 Sep 2011 19:26:04 +0200
Message-ID: <1315070771-18576-5-git-send-email-kaber@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1315070771-18576-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Netlink doesn't account skbs to the sending socket, so the there's no
need to orphan the skb before trimming it.

Removing the skb_orphan() call is required for mmap'ed netlink, which uses
a netlink specific skb destructor that must not be invoked before the
final freeing of the skb.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a9f876b..7b9d7d0 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -862,7 +862,7 @@ static inline struct sk_buff *netlink_trim(struct sk_buff *skb,
 {
 	int delta;
 
-	skb_orphan(skb);
+	WARN_ON(skb->sk != NULL);
 
 	delta = skb->end - skb->tail;
 	if (delta * 2 < skb->truesize)
-- 
1.7.4.4

