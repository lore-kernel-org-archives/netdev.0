From: Patrick McHardy <kaber@trash.net>
Subject: [NETLINK]: Mark attribute construction exception unlikely
Date: Wed, 05 Dec 2007 12:19:17 +0100
Message-ID: <47568935.3040704@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090602020308020904030703"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59433 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbXLELTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 06:19:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090602020308020904030703
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------090602020308020904030703
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETLINK]: Mark attribute construction exception unlikely

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9fce717f589c67137fbfc3b202d3d107dd613ad7
tree efc61e4abeeb2a89cad629c719e528364fb8dcdd
parent d426bc47b4c14d6d60b35d1b79c7d598704bbf04
author Patrick McHardy <kaber@trash.net> Tue, 04 Dec 2007 10:48:28 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 05 Dec 2007 12:17:13 +0100

 include/linux/netlink.h |    2 +-
 include/net/netlink.h   |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index d5bfaba..2aee0f5 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -245,7 +245,7 @@ __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 }
 
 #define NLMSG_NEW(skb, pid, seq, type, len, flags) \
-({	if (skb_tailroom(skb) < (int)NLMSG_SPACE(len)) \
+({	if (unlikely(skb_tailroom(skb) < (int)NLMSG_SPACE(len))) \
 		goto nlmsg_failure; \
 	__nlmsg_put(skb, pid, seq, type, len, flags); })
 
diff --git a/include/net/netlink.h b/include/net/netlink.h
index 9298218..db4b935 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -862,7 +862,7 @@ static inline int nla_put_msecs(struct sk_buff *skb, int attrtype,
 
 #define NLA_PUT(skb, attrtype, attrlen, data) \
 	do { \
-		if (nla_put(skb, attrtype, attrlen, data) < 0) \
+		if (unlikely(nla_put(skb, attrtype, attrlen, data) < 0)) \
 			goto nla_put_failure; \
 	} while(0)
 

--------------090602020308020904030703--
