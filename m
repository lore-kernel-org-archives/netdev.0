From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] dst: don't inline dst_ifdown
Date: Mon, 12 Apr 2010 10:38:05 -0700
Message-ID: <20100412103805.13ac6339@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56707 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432Ab0DLRi1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 13:38:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function dst_ifdown is called only two places but in a non-
performance critical code path, there is no reason to inline it.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/dst.c	2010-04-11 12:30:44.228996074 -0700
+++ b/net/core/dst.c	2010-04-11 12:32:15.488707752 -0700
@@ -285,8 +285,8 @@ EXPORT_SYMBOL(dst_release);
  *
  * Commented and originally written by Alexey.
  */
-static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
-			      int unregister)
+static void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
+		       int unregister)
 {
 	if (dst->ops->ifdown)
 		dst->ops->ifdown(dst, dev, unregister);
