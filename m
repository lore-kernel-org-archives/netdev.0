From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] neighbor: use ALIGN() macro
Date: Thu, 10 Aug 2006 11:34:03 -0700
Message-ID: <20060810113403.6d46e567@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61842 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751454AbWHJSeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 14:34:25 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rather than opencoding the mask, it looks better to use ALIGN()
macro from kernel.h.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- net-2.6.19.orig/include/net/neighbour.h
+++ net-2.6.19/include/net/neighbour.h
@@ -101,7 +101,7 @@ struct neighbour
 	__u8			dead;
 	atomic_t		probes;
 	rwlock_t		lock;
-	unsigned char		ha[(MAX_ADDR_LEN+sizeof(unsigned long)-1)&~(sizeof(unsigned long)-1)];
+	unsigned char		ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
 	struct hh_cache		*hh;
 	atomic_t		refcnt;
 	int			(*output)(struct sk_buff *skb);
