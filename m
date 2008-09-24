From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 1/4] enic: Don't indicate IPv6 pkts using soft-LRO
Date: Wed, 24 Sep 2008 11:23:22 -0700
Message-ID: <20080924182322.22778.63322.stgit@palito_client100.nuovasystems.com>
References: <20080924182154.22778.76605.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:1240 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbYIXSYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 14:24:13 -0400
In-Reply-To: <20080924182154.22778.76605.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: Don't indicate IPv6 pkts using soft-LRO

LRO is only applied to IPv4 pkts, so don't use the LRO indication functions
for anything other IPv4 pkts.  Every non-IPv4 pkt is indicated using non-
LRO functions.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 2592e52..6284594 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -942,7 +942,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		if (enic->vlan_group && vlan_stripped) {
 
-			if (ENIC_SETTING(enic, LRO))
+			if (ENIC_SETTING(enic, LRO) && ipv4)
 				lro_vlan_hwaccel_receive_skb(&enic->lro_mgr,
 					skb, enic->vlan_group,
 					vlan, cq_desc);
@@ -952,7 +952,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		} else {
 
-			if (ENIC_SETTING(enic, LRO))
+			if (ENIC_SETTING(enic, LRO) && ipv4)
 				lro_receive_skb(&enic->lro_mgr, skb, cq_desc);
 			else
 				netif_receive_skb(skb);

