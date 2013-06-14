From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 2/8] openvswitch: Remove unused get_config vport op.
Date: Fri, 14 Jun 2013 15:28:51 -0700
Message-ID: <1371248937-35614-3-git-send-email-jesse@nicira.com>
References: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Cc: netdev <netdev@vger.kernel.org>, dev@openvswitch.org,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:57756 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753476Ab3FNW3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 18:29:06 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so984724pbc.4
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 15:29:05 -0700 (PDT)
In-Reply-To: <1371248937-35614-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The get_config vport op is left over from old compatibility code,
it is neither used nor implemented any more.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/vport-netdev.h | 1 -
 net/openvswitch/vport.h        | 3 ---
 2 files changed, 4 deletions(-)

diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index a3cb3a3..dd298b5 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -39,6 +39,5 @@ netdev_vport_priv(const struct vport *vport)
 }
 
 const char *ovs_netdev_get_name(const struct vport *);
-const char *ovs_netdev_get_config(const struct vport *);
 
 #endif /* vport_netdev.h */
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 68a377b..26c594b 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -123,8 +123,6 @@ struct vport_parms {
  * existing vport to a &struct sk_buff.  May be %NULL for a vport that does not
  * have any configuration.
  * @get_name: Get the device's name.
- * @get_config: Get the device's configuration.
- * May be null if the device does not have an ifindex.
  * @send: Send a packet on the device.  Returns the length of the packet sent.
  */
 struct vport_ops {
@@ -139,7 +137,6 @@ struct vport_ops {
 
 	/* Called with rcu_read_lock or ovs_mutex. */
 	const char *(*get_name)(const struct vport *);
-	void (*get_config)(const struct vport *, void *);
 
 	int (*send)(struct vport *, struct sk_buff *);
 };
-- 
1.8.1.2
