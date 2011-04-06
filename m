From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 08/20] net-l2tp: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:13 -0700
Message-ID: <1302050665-10460-9-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
 <1302050665-10460-4-git-send-email-maheshb@google.com>
 <1302050665-10460-5-git-send-email-maheshb@google.com>
 <1302050665-10460-6-git-send-email-maheshb@google.com>
 <1302050665-10460-7-git-send-email-maheshb@google.com>
 <1302050665-10460-8-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28061 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102Ab1DFAoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:54 -0400
In-Reply-To: <1302050665-10460-8-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/l2tp/l2tp_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index c64ce0a..265cda5 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1081,7 +1081,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 		if (sk->sk_no_check == UDP_CSUM_NOXMIT)
 			skb->ip_summed = CHECKSUM_NONE;
 		else if ((skb_dst(skb) && skb_dst(skb)->dev) &&
-			 (!(skb_dst(skb)->dev->features & NETIF_F_V4_CSUM))) {
+			 (!(skb_dst(skb)->dev->legacy_features & NETIF_F_V4_CSUM))) {
 			skb->ip_summed = CHECKSUM_COMPLETE;
 			csum = skb_checksum(skb, 0, udp_len, 0);
 			uh->check = csum_tcpudp_magic(inet->inet_saddr,
-- 
1.7.3.1

