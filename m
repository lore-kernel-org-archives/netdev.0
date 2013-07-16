From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 2/2] macvtap: do not assume 802.1Q when send vlan packets
Date: Tue, 16 Jul 2013 13:36:34 +0800
Message-ID: <1373952994-7252-2-git-send-email-jasowang@redhat.com>
References: <1373952994-7252-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, Basil Gor <basil.gor@gmail.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373952994-7252-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hard-coded 8021.q proto will break 802.1ad traffic. So switch to use
vlan->proto.

Cc: Basil Gor <basil.gor@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 8270b5e..638b64c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -869,7 +869,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 			__be16 h_vlan_proto;
 			__be16 h_vlan_TCI;
 		} veth;
-		veth.h_vlan_proto = htons(ETH_P_8021Q);
+		veth.h_vlan_proto = skb->vlan_proto;
 		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
 
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
-- 
1.7.1
