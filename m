From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] arp: add macro to get drop_gratuitous_arp setting
Date: Tue,  8 Mar 2016 07:53:50 +0000
Message-ID: <1457423630-12676-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8341 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbcCHHvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 02:51:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add macro IN_DEV_DROP_GRATUITOUS_ARP to facilitate getting
drop_gratuitous_arp value.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 include/linux/inetdevice.h | 3 +++
 net/ipv4/arp.c             | 2 +-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ee971f3..9d1dd2c 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -128,6 +128,9 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_ARP_ANNOUNCE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_ANNOUNCE)
 #define IN_DEV_ARP_IGNORE(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
 #define IN_DEV_ARP_NOTIFY(in_dev)	IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
+#define IN_DEV_DROP_GRATUITOUS_ARP(in_dev) \
+					IN_DEV_ORCONF((in_dev), \
+						      DROP_GRATUITOUS_ARP)
 
 struct in_ifaddr {
 	struct hlist_node	hash;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c34c754..0bf5cca 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -740,7 +740,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
   *	there will be an ARP proxy and gratuitous ARP frames are attacks
   *	and thus should not be accepted.
   */
-	if (sip == tip && IN_DEV_ORCONF(in_dev, DROP_GRATUITOUS_ARP))
+	if (sip == tip && IN_DEV_DROP_GRATUITOUS_ARP(in_dev))
 		goto out_free_skb;
 
 /*
-- 
1.8.3.1
