From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net 2/2] net: vxlan: lwt: Fix vxlan local traffic.
Date: Fri,  5 Aug 2016 17:45:37 -0700
Message-ID: <1470444337-3725-2-git-send-email-pshelar@ovn.org>
References: <1470444337-3725-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:55564 "EHLO
	slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbcHFULM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2016 16:11:12 -0400
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
	by slow1-d.mail.gandi.net (Postfix) with ESMTP id C967E47A4ED
	for <netdev@vger.kernel.org>; Sat,  6 Aug 2016 02:46:09 +0200 (CEST)
In-Reply-To: <1470444337-3725-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan driver has bypass for local vxlan traffic, but that
depends on information about all VNIs on local system in
vxlan driver. This is not available in case of LWT.
Therefore following patch disable encap bypass for LWT
vxlan traffic.

Fixes: ee122c79d42 ("vxlan: Flow based tunneling").
Reported-by: Jakub Libosvar <jlibosva@redhat.com>
Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/vxlan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index b812234..c0dda6f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2022,7 +2022,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		/* Bypass encapsulation if the destination is local */
-		if (rt->rt_flags & RTCF_LOCAL &&
+		if (!info && rt->rt_flags & RTCF_LOCAL &&
 		    !(rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
 			struct vxlan_dev *dst_vxlan;
 
@@ -2082,7 +2082,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 
 		/* Bypass encapsulation if the destination is local */
 		rt6i_flags = ((struct rt6_info *)ndst)->rt6i_flags;
-		if (rt6i_flags & RTF_LOCAL &&
+		if (!info && rt6i_flags & RTF_LOCAL &&
 		    !(rt6i_flags & (RTCF_BROADCAST | RTCF_MULTICAST))) {
 			struct vxlan_dev *dst_vxlan;
 
-- 
1.9.1
