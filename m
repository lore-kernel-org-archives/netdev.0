From: Yi Zou <yi.zou@intel.com>
Subject: [net-next PATCH v1] 8021q: fix vlan device to inherit the unicast
	filtering capability flag
Date: Wed, 28 Nov 2012 15:45:24 -0800
Message-ID: <20121128234520.6615.41220.stg.yi.zou@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: devel@open-fcoe.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13673 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945979Ab2K2AdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 19:33:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug is observed on running FCoE over a VLAN device associated w/
a real device that has IFF_UNICAST_FLT set since FCoE would add unicast
address such as FLOGI MAC to the VLAN interface that FCoE is on. Since
currently, VLAN device is not inheriting the IFF_UNICAST_FLT flag from the
parent real device even though the real device is capable of doing unicast
filtering. This forces the VLAN device and its real device go to promiscuous
mode unnecessarily even the added address is actually being added to the
available unicast filter table in real device.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Cc: devel@open-fcoe.org
---

 net/8021q/vlan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ee07072..ca03c17 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -242,6 +242,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	 * hope the underlying device can handle it.
 	 */
 	new_dev->mtu = real_dev->mtu;
+	new_dev->priv_flags |= (real_dev->priv_flags & IFF_UNICAST_FLT);
 
 	vlan_dev_priv(new_dev)->vlan_id = vlan_id;
 	vlan_dev_priv(new_dev)->real_dev = real_dev;
