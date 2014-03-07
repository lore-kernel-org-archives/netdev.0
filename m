From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/2] vlan: add proto for proc interface
Date: Fri, 7 Mar 2014 20:10:50 +0800
Message-ID: <1394194251-11656-2-git-send-email-dingtianhong@huawei.com>
References: <1394194251-11656-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:19470 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbaCGMLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 07:11:25 -0500
In-Reply-To: <1394194251-11656-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vlan could support 2 proto: 802.1q and 802.1ad, so add it to
proc interface, the user could easily distinguish the proto for
each vlan dev.

And the dev->priv_flags seems inappropriate, modify to Priv_Flags,
looks more comfortable.

---------------------- the old format: --------------------------

eth2.10  VID: 10         REORDER_HDR: 1  dev->priv_flags: 1
         total frames received            5
          total bytes received          336
      Broadcast/Multicast Rcvd            0

      total frames transmitted           13
       total bytes transmitted         1026
Device: eth2
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
 EGRESS priority mappings:

----------------------- the new format: -------------------------

eth2.20  Proto: 802.1q  VID: 20  REORDER_HDR: 1  Priv_Flags: 1
         total frames received            0
          total bytes received            0
      Broadcast/Multicast Rcvd            0

      total frames transmitted            0
       total bytes transmitted            0
Device: eth2
INGRESS priority mappings: 0:0  1:0  2:0  3:0  4:0  5:0  6:0 7:0
 EGRESS priority mappings:

----------------------------------------------------------------

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/8021q/vlanproc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 1d0e8921..a40abbc 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -285,8 +285,10 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 
 	stats = dev_get_stats(vlandev, &temp);
 	seq_printf(seq,
-		   "%s  VID: %d	 REORDER_HDR: %i  dev->priv_flags: %hx\n",
-		   vlandev->name, vlan->vlan_id,
+		   "%s  Proto: %s  VID: %d  REORDER_HDR: %i  Priv_Flags: %hx\n",
+		   vlandev->name,
+		   vlan->vlan_proto == htons(ETH_P_8021Q) ? "802.1q" : "802.1ad",
+		   vlan->vlan_id,
 		   (int)(vlan->flags & 1), vlandev->priv_flags);
 
 	seq_printf(seq, fmt64, "total frames received", stats->rx_packets);
-- 
1.8.0
