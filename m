From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 09/11] net: ipv6: hlen could be set as size_t
Date: Fri, 23 Oct 2015 14:10:34 +0200
Message-ID: <1445602236-24130-10-git-send-email-clabbe.montjoie@gmail.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, jmorris@namei.org, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hlen member of raw6_frag_vec is used in operation/function that
wait for unsigned value. So it need to be set as size_t.

This patch do the same for the hlen variable.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 net/ipv6/raw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 5d9404b..434e9ad 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -618,7 +618,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, size_t length,
 	struct sk_buff *skb;
 	int err;
 	struct rt6_info *rt = (struct rt6_info *)*dstp;
-	int hlen = LL_RESERVED_SPACE(rt->dst.dev);
+	size_t hlen = LL_RESERVED_SPACE(rt->dst.dev);
 	int tlen = rt->dst.dev->needed_tailroom;
 
 	if (length > rt->dst.dev->mtu) {
@@ -674,7 +674,7 @@ error:
 
 struct raw6_frag_vec {
 	struct msghdr *msg;
-	int hlen;
+	size_t hlen;
 	char c[4];
 };
 
-- 
2.4.10
