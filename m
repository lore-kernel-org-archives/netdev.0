From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/10][RTNL]: Relax for_each_netdev_safe in __rtnl_link_unregister.
Date: Tue, 15 Apr 2008 16:01:53 +0400
Message-ID: <48049931.9000209@openvz.org>
References: <4804989F.1060503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39537 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764332AbYDOL1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:27:34 -0400
In-Reply-To: <4804989F.1060503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each potential list_del (happening from inside a ->dellink call)
is followed by goto restart, so there's no need in _safe iteration.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/core/rtnetlink.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index da99ac0..edc6dbf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -277,12 +277,12 @@ EXPORT_SYMBOL_GPL(rtnl_link_register);
  */
 void __rtnl_link_unregister(struct rtnl_link_ops *ops)
 {
-	struct net_device *dev, *n;
+	struct net_device *dev;
 	struct net *net;
 
 	for_each_net(net) {
 restart:
-		for_each_netdev_safe(net, dev, n) {
+		for_each_netdev(net, dev) {
 			if (dev->rtnl_link_ops == ops) {
 				ops->dellink(dev);
 				goto restart;
-- 
1.5.3.4


