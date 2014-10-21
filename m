From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] netlink: don't copy over empty attribute data
Date: Tue, 21 Oct 2014 16:51:09 -0400
Message-ID: <1413924669-26732-1-git-send-email-sasha.levin@oracle.com>
Cc: a.ryabinin@samsung.com, pablo@netfilter.org, mschmidt@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netlink uses empty data to seperate different levels. However, we still
try to copy that data from a NULL ptr using memcpy, which is an undefined
behaviour.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 lib/nlattr.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/nlattr.c b/lib/nlattr.c
index 9c3e85f..6512b43 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -430,7 +430,8 @@ void __nla_put(struct sk_buff *skb, int attrtype, int attrlen,
 	struct nlattr *nla;
 
 	nla = __nla_reserve(skb, attrtype, attrlen);
-	memcpy(nla_data(nla), data, attrlen);
+	if (data)
+		memcpy(nla_data(nla), data, attrlen);
 }
 EXPORT_SYMBOL(__nla_put);
 
-- 
1.7.10.4
