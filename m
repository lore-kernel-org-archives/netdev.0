From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 1/2] net: declare new net_device priv_flag IFF_NO_QUEUE
Date: Thu, 13 Aug 2015 19:01:06 +0200
Message-ID: <1439485268-20953-2-git-send-email-phil@nwl.cc>
References: <1439485268-20953-1-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, alexei.starovoitov@gmail.com,
	davem@davemloft.net, fw@strlen.de, cwang@twopensource.com,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:58888 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753271AbbHMRBK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2015 13:01:10 -0400
In-Reply-To: <1439485268-20953-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This private net_device flag can be set by drivers to inform that a
device runs fine without a qdisc attached. This was formerly done by
setting tx_queue_len to zero.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/linux/netdevice.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 607b5f4..7ed6fb0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1262,6 +1262,7 @@ struct net_device_ops {
  * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
  *	change when it's running
  * @IFF_MACVLAN: Macvlan device
+ * @IFF_NO_QUEUE: device can run without qdisc attached
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1289,6 +1290,7 @@ enum netdev_priv_flags {
 	IFF_XMIT_DST_RELEASE_PERM	= 1<<22,
 	IFF_IPVLAN_MASTER		= 1<<23,
 	IFF_IPVLAN_SLAVE		= 1<<24,
+	IFF_NO_QUEUE			= 1<<25,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1316,6 +1318,7 @@ enum netdev_priv_flags {
 #define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
 #define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
 #define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
+#define IFF_NO_QUEUE			IFF_NO_QUEUE
 
 /**
  *	struct net_device - The DEVICE structure.
-- 
2.1.2
