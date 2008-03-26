From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/2 net-2.6.26] [NETNS]: Compilation warnings under CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 10:40:59 +0300
Message-ID: <1206517259-29152-2-git-send-email-den@openvz.org>
References: <1206517259-29152-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:59074 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750934AbYCZHki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 03:40:38 -0400
In-Reply-To: <1206517259-29152-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent commits from YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
have been introduced a several compilation warnings
'assignment discards qualifiers from pointer target type'
due to extra const modifier in the inline call parameters of
{dev|sock|twsk}_net_set.

Drop it.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/linux/netdevice.h        |    2 +-
 include/net/inet_timewait_sock.h |    2 +-
 include/net/sock.h               |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 06ca84d..15fa84a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -753,7 +753,7 @@ struct net *dev_net(const struct net_device *dev)
 }
 
 static inline
-void dev_net_set(struct net_device *dev, const struct net *net)
+void dev_net_set(struct net_device *dev, struct net *net)
 {
 #ifdef CONFIG_NET_NS
 	dev->nd_net = net;
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 07fe0d1..95c660c 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -219,7 +219,7 @@ struct net *twsk_net(const struct inet_timewait_sock *twsk)
 }
 
 static inline
-void twsk_net_set(struct inet_timewait_sock *twsk, const struct net *net)
+void twsk_net_set(struct inet_timewait_sock *twsk, struct net *net)
 {
 #ifdef CONFIG_NET_NS
 	twsk->tw_net = net;
diff --git a/include/net/sock.h b/include/net/sock.h
index 7e0d4a0..1c9d059 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1358,7 +1358,7 @@ struct net *sock_net(const struct sock *sk)
 }
 
 static inline
-void sock_net_set(struct sock *sk, const struct net *net)
+void sock_net_set(struct sock *sk, struct net *net)
 {
 #ifdef CONFIG_NET_NS
 	sk->sk_net = net;
-- 
1.5.3.rc5

