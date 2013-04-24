From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH net-next] netlink: compiling issue, need a dummy function
 sk_diag_put_rings_cfg when CONFIG_NETLINK_MMAP disabled
Date: Wed, 24 Apr 2013 16:09:43 +0800
Message-ID: <51779347.2000808@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, kaber@trash.net,
	xemul@parallels.com, avagin@openvz.org,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:25991 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757849Ab3DXIKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 04:10:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When disable CONFIG_NETLINK_MMAP, need a dummy function for 
sk_diag_put_rings_cfg, or will cause compiling issue.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/netlink/diag.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 4e4aa47..d0ab090 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -7,6 +7,8 @@
 
 #include "af_netlink.h"
 
+#ifdef CONFIG_NETLINK_MMAP
+
 static int sk_diag_put_ring(struct netlink_ring *ring, int nl_type,
 			    struct sk_buff *nlskb)
 {
@@ -35,6 +37,15 @@ static int sk_diag_put_rings_cfg(struct sock *sk, struct sk_buff *nlskb)
 	return ret;
 }
 
+#else /* !CONFIG_NETLINK_MMAP */
+
+static int sk_diag_put_rings_cfg(struct sock *sk, struct sk_buff *nlskb)
+{
+	return 0;
+}
+
+#endif /* CONFIG_NETLINK_MMAP */
+
 static int sk_diag_dump_groups(struct sock *sk, struct sk_buff *nlskb)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
-- 
1.7.7.6
