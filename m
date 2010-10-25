From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/4] ipv6: ip6_ptr rcu annotations
Date: Mon, 25 Oct 2010 09:32:05 +0200
Message-ID: <1287991925.2658.5380.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45863 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab0JYHcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 03:32:16 -0400
Received: by wyf28 with SMTP id 28so3014985wyf.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 00:32:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(struct net_device)->ip6_ptr is rcu protected :

add __rcu annotation and proper rcu primitives.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ceefb441..4722d4a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -952,7 +952,7 @@ struct net_device {
 	void 			*atalk_ptr;	/* AppleTalk link 	*/
 	struct in_device __rcu	*ip_ptr;	/* IPv4 specific data	*/
 	void                    *dn_ptr;        /* DECnet specific data */
-	void                    *ip6_ptr;       /* IPv6 specific data */
+	struct inet6_dev __rcu	*ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
 	void			*ax25_ptr;	/* AX.25 specific data */
 	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
diff --git a/net/core/dev.c b/net/core/dev.c
index 78b5a89..63fd9d9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5416,7 +5416,7 @@ void netdev_run_todo(void)
 		/* paranoia */
 		BUG_ON(netdev_refcnt_read(dev));
 		WARN_ON(rcu_dereference_raw(dev->ip_ptr));
-		WARN_ON(dev->ip6_ptr);
+		WARN_ON(rcu_dereference_raw(dev->ip6_ptr));
 		WARN_ON(dev->dn_ptr);
 
 		if (dev->destructor)


