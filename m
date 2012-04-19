From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] nf_bridge: remove holes in struct nf_bridge_info
Date: Thu, 19 Apr 2012 11:19:25 +0200
Message-ID: <1334827165.2395.63.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61031 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753824Ab2DSJTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 05:19:30 -0400
Received: by bkcik5 with SMTP id ik5so6148008bkc.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 02:19:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Put use & mask on same location to avoid two holes on 64bit arches

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 775292a..f25795c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -117,11 +117,11 @@ struct nf_conntrack {
 
 #ifdef CONFIG_BRIDGE_NETFILTER
 struct nf_bridge_info {
-	atomic_t use;
-	struct net_device *physindev;
-	struct net_device *physoutdev;
-	unsigned int mask;
-	unsigned long data[32 / sizeof(unsigned long)];
+	atomic_t		use;
+	unsigned int		mask;
+	struct net_device	*physindev;
+	struct net_device	*physoutdev;
+	unsigned long		data[32 / sizeof(unsigned long)];
 };
 #endif
 
