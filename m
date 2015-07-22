From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] vxlan: Use proper endian type for vni in vxlan[6]_xmit_skb
Date: Wed, 22 Jul 2015 17:08:42 +0200
Message-ID: <43ce50f9da21ebe190cfd6d41b334978250c061d.1437576553.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54154 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932693AbbGVPIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 11:08:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Silences the following sparse warnings:
drivers/net/vxlan.c:1818:21: warning: incorrect type in assignment (different base types)
drivers/net/vxlan.c:1818:21:    expected restricted __be32 [usertype] vx_vni
drivers/net/vxlan.c:1818:21:    got unsigned int [unsigned] [usertype] vni
drivers/net/vxlan.c:2014:58: warning: incorrect type in argument 11 (different base types)
drivers/net/vxlan.c:2014:58:    expected unsigned int [unsigned] [usertype] vni
drivers/net/vxlan.c:2014:58:    got restricted __be32 [usertype] <noident>

Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e9feefb..81f0f24 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1686,7 +1686,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
 			   struct sk_buff *skb,
 			   struct net_device *dev, struct in6_addr *saddr,
 			   struct in6_addr *daddr, __u8 prio, __u8 ttl,
-			   __be16 src_port, __be16 dst_port, __u32 vni,
+			   __be16 src_port, __be16 dst_port, __be32 vni,
 			   struct vxlan_metadata *md, bool xnet, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
@@ -1771,7 +1771,7 @@ err:
 
 static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *skb,
 			  __be32 src, __be32 dst, __u8 tos, __u8 ttl, __be16 df,
-			  __be16 src_port, __be16 dst_port, __u32 vni,
+			  __be16 src_port, __be16 dst_port, __be32 vni,
 			  struct vxlan_metadata *md, bool xnet, u32 vxflags)
 {
 	struct vxlanhdr *vxh;
-- 
2.4.3
