From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 06/08]: Use 32 bit value for skb->priority mapping
Date: Tue,  5 Jun 2007 16:23:38 +0200 (MEST)
Message-ID: <20070605142337.20372.38001.sendpatchset@localhost.localdomain>
References: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64172 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764424AbXFEOXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:23:40 -0400
In-Reply-To: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Use 32 bit value for skb->priority mapping

skb->priority has only 32 bits and even VLAN uses 32 bit values in its
API.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 24b7a56049e5e9f63e6fc5933d10b47c15294fea
tree 7c1d37c5c3b9f09c3c7d726d6fa922454d57bf16
parent c59e99d32d8085f8ed1aa794106c28e546220581
author Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 17:52:48 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 17:52:48 +0200

 include/linux/if_vlan.h |    4 ++--
 net/8021q/vlanproc.c    |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 81e9bc9..1889b29 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -99,7 +99,7 @@ static inline void vlan_group_set_device(struct vlan_group *vg, int vlan_id,
 }
 
 struct vlan_priority_tci_mapping {
-	unsigned long priority;
+	unsigned int priority;
 	unsigned short vlan_qos; /* This should be shifted when first set, so we only do it
 				  * at provisioning time.
 				  * ((skb->priority << 13) & 0xE000)
@@ -112,7 +112,7 @@ struct vlan_dev_info {
 	/** This will be the mapping that correlates skb->priority to
 	 * 3 bits of VLAN QOS tags...
 	 */
-	unsigned long ingress_priority_map[8];
+	unsigned int ingress_priority_map[8];
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
