From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 15/18]: Use 32 bit value for skb->priority mapping
Date: Wed, 13 Jun 2007 18:51:02 +0200 (MEST)
Message-ID: <20070613165059.7780.923.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35969 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758825AbXFMQvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:51:04 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Use 32 bit value for skb->priority mapping

skb->priority has only 32 bits and even VLAN uses 32 bit values in its API.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit a285e1ab7cfb856fc9e503eefd507eb7958b7524
tree 0f95eb6c73eedc66a305bb0ca5cd1ee1391b47d3
parent 5924a55528b3a6897ea49f4af9fa7dcefc50fd57
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:46:57 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:33 +0200

 include/linux/if_vlan.h |    4 ++--
 net/8021q/vlanproc.c    |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 81e9bc9..aeddb49 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -99,7 +99,7 @@ static inline void vlan_group_set_device(struct vlan_group *vg, int vlan_id,
 }
 
 struct vlan_priority_tci_mapping {
-	unsigned long priority;
+	u32 priority;
 	unsigned short vlan_qos; /* This should be shifted when first set, so we only do it
 				  * at provisioning time.
 				  * ((skb->priority << 13) & 0xE000)
@@ -112,7 +112,7 @@ struct vlan_dev_info {
 	/** This will be the mapping that correlates skb->priority to
 	 * 3 bits of VLAN QOS tags...
 	 */
-	unsigned long ingress_priority_map[8];
+	u32 ingress_priority_map[8];
 	struct vlan_priority_tci_mapping *egress_priority_map[16]; /* hash table */
 
 	unsigned short vlan_id;        /*  The VLAN Identifier for this interface. */
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index d216a64..8693b21 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -342,7 +342,7 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 	seq_printf(seq, "Device: %s", dev_info->real_dev->name);
 	/* now show all PRIORITY mappings relating to this VLAN */
 	seq_printf(seq,
-		       "\nINGRESS priority mappings: 0:%lu  1:%lu  2:%lu  3:%lu  4:%lu  5:%lu  6:%lu 7:%lu\n",
+		       "\nINGRESS priority mappings: 0:%u  1:%u  2:%u  3:%u  4:%u  5:%u  6:%u 7:%u\n",
 		       dev_info->ingress_priority_map[0],
 		       dev_info->ingress_priority_map[1],
 		       dev_info->ingress_priority_map[2],
@@ -357,7 +357,7 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 		const struct vlan_priority_tci_mapping *mp
 			= dev_info->egress_priority_map[i];
 		while (mp) {
-			seq_printf(seq, "%lu:%hu ",
+			seq_printf(seq, "%u:%hu ",
 				   mp->priority, ((mp->vlan_qos >> 13) & 0x7));
 			mp = mp->next;
 		}
