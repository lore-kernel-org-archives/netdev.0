From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [VLAN]: Avoid expensive divides
Date: Tue, 08 Jan 2008 12:28:52 +0100
Message-ID: <47835E74.4040900@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000507060107000307000209"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:39713 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754337AbYAHL3J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 06:29:09 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2f16.orange.fr (SMTP Server) with ESMTP id AE6D070000AB
	for <netdev@vger.kernel.org>; Tue,  8 Jan 2008 12:29:05 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000507060107000307000209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

We can avoid divides (as seen with CONFIG_CC_OPTIMIZE_FOR_SIZE=y on x86)
changing vlan_group_get_device()/vlan_group_set_device()  id parameter 
from signed to
unsigned.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------000507060107000307000209
Content-Type: text/plain;
 name="if_vlan.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="if_vlan.patch"

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 976d4b1..4562105 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -81,14 +81,16 @@ struct vlan_group {
 	struct rcu_head		rcu;
 };
 
-static inline struct net_device *vlan_group_get_device(struct vlan_group *vg, int vlan_id)
+static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
+						       unsigned int vlan_id)
 {
 	struct net_device **array;
 	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
 	return array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN];
 }
 
-static inline void vlan_group_set_device(struct vlan_group *vg, int vlan_id,
+static inline void vlan_group_set_device(struct vlan_group *vg,
+					 unsigned int vlan_id,
 					 struct net_device *dev)
 {
 	struct net_device **array;

--------------000507060107000307000209--


