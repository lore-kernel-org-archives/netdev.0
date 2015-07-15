From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/16] i40e: Remove incorrect #ifdef's
Date: Tue, 14 Jul 2015 18:30:31 -0700
Message-ID: <1436923840-24455-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55935 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594AbbGOBar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 21:30:47 -0400
In-Reply-To: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch removes some #ifdef's that should not be there. They
were stopping code that is needed from being compiled in.

With these #ifdef's removed, changes are needed in the driver
to fix some compile errors: adding missing parameters to
the definition of ndo_bridge_setlink and a ndo_dflt_brige_getlink call.

Change-ID: I5516614e1bc50b6bca0647cef971bc96161ba2de
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ed6fc52..c7f2a0a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7993,7 +7993,6 @@ static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	return err;
 }
 
-#ifdef HAVE_BRIDGE_ATTRIBS
 /**
  * i40e_ndo_bridge_setlink - Set the hardware bridge mode
  * @dev: the netdev being configured
@@ -8007,7 +8006,8 @@ static int i40e_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
  * bridge mode enabled.
  **/
 static int i40e_ndo_bridge_setlink(struct net_device *dev,
-				   struct nlmsghdr *nlh)
+				   struct nlmsghdr *nlh,
+				   u16 flags)
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -8078,14 +8078,9 @@ static int i40e_ndo_bridge_setlink(struct net_device *dev,
  * Return the mode in which the hardware bridge is operating in
  * i.e VEB or VEPA.
  **/
-#ifdef HAVE_BRIDGE_FILTER
 static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				   struct net_device *dev,
 				   u32 filter_mask, int nlflags)
-#else
-static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
-				   struct net_device *dev, int nlflags)
-#endif /* HAVE_BRIDGE_FILTER */
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -8109,7 +8104,6 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, veb->bridge_mode,
 				       nlflags, 0, 0, filter_mask, NULL);
 }
-#endif /* HAVE_BRIDGE_ATTRIBS */
 
 #define I40E_MAX_TUNNEL_HDR_LEN 80
 /**
@@ -8165,10 +8159,8 @@ static const struct net_device_ops i40e_netdev_ops = {
 	.ndo_get_phys_port_id	= i40e_get_phys_port_id,
 	.ndo_fdb_add		= i40e_ndo_fdb_add,
 	.ndo_features_check	= i40e_features_check,
-#ifdef HAVE_BRIDGE_ATTRIBS
 	.ndo_bridge_getlink	= i40e_ndo_bridge_getlink,
 	.ndo_bridge_setlink	= i40e_ndo_bridge_setlink,
-#endif /* HAVE_BRIDGE_ATTRIBS */
 };
 
 /**
-- 
2.4.3
