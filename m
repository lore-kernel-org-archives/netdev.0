From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 2/5] openvswitch: Avoid useless holes in struct vport
Date: Fri, 15 Mar 2013 10:38:48 -0700
Message-ID: <1363369131-16830-3-git-send-email-jesse@nicira.com>
References: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Thomas Graf <tgraf@suug.ch>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:51075 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751901Ab3CORjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 13:39:03 -0400
Received: by mail-oa0-f72.google.com with SMTP id j6so18927113oag.11
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 10:39:02 -0700 (PDT)
In-Reply-To: <1363369131-16830-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>

Having the 16bit port_no in between a set of pointers creates
an unwanted and useless hole in the struct.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 3f7961e..aee7d43 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -68,10 +68,10 @@ struct vport_err_stats {
 /**
  * struct vport - one port within a datapath
  * @rcu: RCU callback head for deferred destruction.
- * @port_no: Index into @dp's @ports array.
  * @dp: Datapath to which this port belongs.
  * @upcall_portid: The Netlink port to use for packets received on this port that
  * miss the flow table.
+ * @port_no: Index into @dp's @ports array.
  * @hash_node: Element in @dev_table hash table in vport.c.
  * @dp_hash_node: Element in @datapath->ports hash table in datapath.c.
  * @ops: Class structure.
@@ -81,9 +81,9 @@ struct vport_err_stats {
  */
 struct vport {
 	struct rcu_head rcu;
-	u16 port_no;
 	struct datapath	*dp;
 	u32 upcall_portid;
+	u16 port_no;
 
 	struct hlist_node hash_node;
 	struct hlist_node dp_hash_node;
-- 
1.7.10.4
