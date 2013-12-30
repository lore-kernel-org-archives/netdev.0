From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netlink: cleanup tap related functions
Date: Mon, 30 Dec 2013 10:49:22 -0800
Message-ID: <20131230104922.7b16965e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:38476 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab3L3St0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 13:49:26 -0500
Received: by mail-pd0-f170.google.com with SMTP id g10so11597589pdj.15
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 10:49:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanups in netlink_tap code
 * remove unused function netlink_clear_multicast_users
 * make local function static

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/linux/netlink.h  |    2 --
 net/netlink/af_netlink.c |   18 +-----------------
 2 files changed, 1 insertion(+), 19 deletions(-)

--- a/include/linux/netlink.h	2013-12-24 15:14:54.530174175 -0800
+++ b/include/linux/netlink.h	2013-12-24 15:16:01.721271435 -0800
@@ -62,7 +62,6 @@ extern void netlink_kernel_release(struc
 extern int __netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern int netlink_change_ngroups(struct sock *sk, unsigned int groups);
 extern void __netlink_clear_multicast_users(struct sock *sk, unsigned int group);
-extern void netlink_clear_multicast_users(struct sock *sk, unsigned int group);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_has_listeners(struct sock *sk, unsigned int group);
 extern struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
@@ -168,7 +167,6 @@ struct netlink_tap {
 };
 
 extern int netlink_add_tap(struct netlink_tap *nt);
-extern int __netlink_remove_tap(struct netlink_tap *nt);
 extern int netlink_remove_tap(struct netlink_tap *nt);
 
 #endif	/* __LINUX_NETLINK_H */
--- a/net/netlink/af_netlink.c	2013-12-24 15:14:54.530174175 -0800
+++ b/net/netlink/af_netlink.c	2013-12-24 15:16:01.721271435 -0800
@@ -131,7 +131,7 @@ int netlink_add_tap(struct netlink_tap *
 }
 EXPORT_SYMBOL_GPL(netlink_add_tap);
 
-int __netlink_remove_tap(struct netlink_tap *nt)
+static int __netlink_remove_tap(struct netlink_tap *nt)
 {
 	bool found = false;
 	struct netlink_tap *tmp;
@@ -155,7 +155,6 @@ out:
 
 	return found ? 0 : -ENODEV;
 }
-EXPORT_SYMBOL_GPL(__netlink_remove_tap);
 
 int netlink_remove_tap(struct netlink_tap *nt)
 {
@@ -2535,21 +2534,6 @@ void __netlink_clear_multicast_users(str
 		netlink_update_socket_mc(nlk_sk(sk), group, 0);
 }
 
-/**
- * netlink_clear_multicast_users - kick off multicast listeners
- *
- * This function removes all listeners from the given group.
- * @ksk: The kernel netlink socket, as returned by
- *	netlink_kernel_create().
- * @group: The multicast group to clear.
- */
-void netlink_clear_multicast_users(struct sock *ksk, unsigned int group)
-{
-	netlink_table_grab();
-	__netlink_clear_multicast_users(ksk, group);
-	netlink_table_ungrab();
-}
-
 struct nlmsghdr *
 __nlmsg_put(struct sk_buff *skb, u32 portid, u32 seq, int type, int len, int flags)
 {
