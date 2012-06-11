From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: keep name_hlist close to name
Date: Mon, 11 Jun 2012 18:36:13 +0200
Message-ID: <1339432573.6001.2429.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60267 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401Ab2FKQgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 12:36:18 -0400
Received: by eaak11 with SMTP id k11so1894872eaa.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 09:36:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__dev_get_by_name() is slow because pm_qos_req has been inserted between
name[] and name_hlist, adding cache misses.

pm_qos_req has nothing to do at the beginning of struct net_device

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d94cb14..a0b84e3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1046,10 +1046,9 @@ struct net_device {
 	 */
 	char			name[IFNAMSIZ];
 
-	struct pm_qos_request	pm_qos_req;
-
-	/* device name hash chain */
+	/* device name hash chain, please keep it close to name[] */
 	struct hlist_node	name_hlist;
+
 	/* snmp alias */
 	char 			*ifalias;
 
@@ -1322,6 +1321,8 @@ struct net_device {
 
 	/* group the device belongs to */
 	int group;
+
+	struct pm_qos_request	pm_qos_req;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
