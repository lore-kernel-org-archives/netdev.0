From: Johannes Berg <johannes@sipsolutions.net>
Subject: netlink: remove subscriptions check on notifier
Date: Mon, 16 Nov 2009 23:05:34 +0100
Message-ID: <1258409134.1375.0.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:57198 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587AbZKPWFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 17:05:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The netlink URELEASE notifier doesn't notify for
sockets that have been used to receive multicast
but it should be called for such sockets as well
since they might _also_ be used for sending and
not solely for receiving multicast. We will need
that for nl80211 (generic netlink sockets) in the
future.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/netlink/af_netlink.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- wireless-testing.orig/net/netlink/af_netlink.c	2009-11-16 23:02:13.000000000 +0100
+++ wireless-testing/net/netlink/af_netlink.c	2009-11-16 23:02:23.000000000 +0100
@@ -497,7 +497,7 @@ static int netlink_release(struct socket
 
 	skb_queue_purge(&sk->sk_write_queue);
 
-	if (nlk->pid && !nlk->subscriptions) {
+	if (nlk->pid) {
 		struct netlink_notify n = {
 						.net = sock_net(sk),
 						.protocol = sk->sk_protocol,


