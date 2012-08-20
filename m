From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 03/11] netlink: don't orphan skb in netlink_trim()
Date: Mon, 20 Aug 2012 08:18:44 +0200
Message-ID: <1345443532-3707-4-git-send-email-kaber@trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345443532-3707-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index 1bdfa52..3233601 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -886,7 +886,7 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 {
 	int delta;
 
-	skb_orphan(skb);
+	WARN_ON(skb->sk != NULL);
 
 	delta = skb->end - skb->tail;
 	if (delta * 2 < skb->truesize)
-- 
1.7.7.6

