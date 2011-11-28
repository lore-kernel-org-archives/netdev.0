From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Subject: [PATCH 2/2] atm: br2684: Avoid alignment issues
Date: Mon, 28 Nov 2011 13:40:43 -0500
Message-ID: <201111281840.pASIehr6011893@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:36903 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410Ab1K1Slo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 13:41:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Pascal Hambourg <pascal@plouf.fr.eu.org>
Date: Wed, 17 Aug 2011 08:37:52 +0200
Subject: [PATCH 2/2] atm: br2684: Avoid alignment issues

Use memcmp() instead of cast to u16 when checking the PAD field.

Signed-off-by: Pascal Hambourg <pascal@plouf.fr.eu.org>
Signed-off-by: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
---
 net/atm/br2684.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index ed72263..353fccf 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -53,6 +53,7 @@ static const unsigned char ethertype_ipv4[] = { ETHERTYPE_IPV4 };
 static const unsigned char ethertype_ipv6[] = { ETHERTYPE_IPV6 };
 static const unsigned char llc_oui_pid_pad[] =
 			{ LLC, SNAP_BRIDGED, PID_ETHERNET, PAD_BRIDGED };
+static const unsigned char pad[] = { PAD_BRIDGED };
 static const unsigned char llc_oui_ipv4[] = { LLC, SNAP_ROUTED, ETHERTYPE_IPV4 };
 static const unsigned char llc_oui_ipv6[] = { LLC, SNAP_ROUTED, ETHERTYPE_IPV6 };
 
@@ -453,7 +454,7 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 			skb->pkt_type = PACKET_HOST;
 		} else { /* p_bridged */
 			/* first 2 chars should be 0 */
-			if (*((u16 *) (skb->data)) != 0)
+			if (memcmp(skb->data, pad, BR2684_PAD_LEN) != 0)
 				goto error;
 			skb_pull(skb, BR2684_PAD_LEN);
 			skb->protocol = eth_type_trans(skb, net_dev);
-- 
1.7.6
