From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: explain netns notifiers a little better
Date: Wed, 15 Jul 2009 18:16:34 +0200
Message-ID: <1247674594.10754.20.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:47504 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350AbZGOQRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 12:17:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric explained this to me -- and afterwards the comment
made sense, but not before. Add the the critical point
about interfaces having to be gone from the netns before
subsys notifiers are called.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 include/net/net_namespace.h |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

--- wireless-testing.orig/include/net/net_namespace.h	2009-07-11 11:18:20.000000000 +0200
+++ wireless-testing/include/net/net_namespace.h	2009-07-11 11:20:49.000000000 +0200
@@ -239,13 +239,15 @@ struct pernet_operations {
  * needs per network namespace operations use device pernet operations,
  * otherwise use pernet subsys operations.
  *
- * This is critically important.  Most of the network code cleanup
- * runs with the assumption that dev_remove_pack has been called so no
- * new packets will arrive during and after the cleanup functions have
- * been called.  dev_remove_pack is not per namespace so instead the
- * guarantee of no more packets arriving in a network namespace is
- * provided by ensuring that all network devices and all sockets have
- * left the network namespace before the cleanup methods are called.
+ * Network interfaces need to be removed from a dying netns _before_
+ * subsys notifiers can be called, as most of the network code cleanup
+ * (which is done from subsys notifiers) runs with the assumption that
+ * dev_remove_pack has been called so no new packets will arrive during
+ * and after the cleanup functions have been called.  dev_remove_pack
+ * is not per namespace so instead the guarantee of no more packets
+ * arriving in a network namespace is provided by ensuring that all
+ * network devices and all sockets have left the network namespace
+ * before the cleanup methods are called.
  *
  * For the longest time the ipv4 icmp code was registered as a pernet
  * device which caused kernel oops, and panics during network


