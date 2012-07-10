From: roy.qing.li@gmail.com
Subject: [v2 PATCH] qlge: fix endian issue
Date: Tue, 10 Jul 2012 16:02:42 +0800
Message-ID: <1341907362-17752-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:46390 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848Ab2GJICz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 04:02:55 -0400
Received: by qcro28 with SMTP id o28so7191904qcr.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 01:02:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

commit 6d29b1ef introduces a bug, ntohs is __be16_to_cpu,
not cpu_to_be16.

We always use htons on IP_OFFSET and IP_MF, then compare
with network package.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
v2 : Change my name
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 09d8d33..7c520fa 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1546,7 +1546,7 @@ static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 			struct iphdr *iph =
 				(struct iphdr *) ((u8 *)addr + ETH_HLEN);
 			if (!(iph->frag_off &
-				cpu_to_be16(IP_MF|IP_OFFSET))) {
+				htons(IP_MF|IP_OFFSET))) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				netif_printk(qdev, rx_status, KERN_DEBUG,
 					     qdev->ndev,
@@ -1654,7 +1654,7 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 			/* Unfragmented ipv4 UDP frame. */
 			struct iphdr *iph = (struct iphdr *) skb->data;
 			if (!(iph->frag_off &
-				ntohs(IP_MF|IP_OFFSET))) {
+				htons(IP_MF|IP_OFFSET))) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				netif_printk(qdev, rx_status, KERN_DEBUG,
 					     qdev->ndev,
@@ -1968,7 +1968,7 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 		/* Unfragmented ipv4 UDP frame. */
 			struct iphdr *iph = (struct iphdr *) skb->data;
 			if (!(iph->frag_off &
-				ntohs(IP_MF|IP_OFFSET))) {
+				htons(IP_MF|IP_OFFSET))) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
 					     "TCP checksum done!\n");
-- 
1.7.1
