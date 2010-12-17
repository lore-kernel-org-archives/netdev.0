From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] ipv6: fib6_ifdown cleanup
Date: Thu, 16 Dec 2010 19:42:40 -0800
Message-ID: <20101216194240.2b231449@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44176 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752218Ab0LQDmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Dec 2010 22:42:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove (unnecessary) casts to make code cleaner.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/route.c	2010-12-16 15:09:42.336361755 -0800
+++ b/net/ipv6/route.c	2010-12-16 17:50:27.997984246 -0800
@@ -2004,11 +2004,11 @@ struct arg_dev_net {
 
 static int fib6_ifdown(struct rt6_info *rt, void *arg)
 {
-	struct net_device *dev = ((struct arg_dev_net *)arg)->dev;
-	struct net *net = ((struct arg_dev_net *)arg)->net;
+	const struct arg_dev_net *adn = arg;
+	const struct net_device *dev = adn->dev;
 
-	if (((void *)rt->rt6i_dev == dev || dev == NULL) &&
-	    rt != net->ipv6.ip6_null_entry) {
+	if ((rt->rt6i_dev == dev || dev == NULL) &&
+	    rt != adn->net->ipv6.ip6_null_entry) {
 		RT6_TRACE("deleted by ifdown %p\n", rt);
 		return -1;
 	}
