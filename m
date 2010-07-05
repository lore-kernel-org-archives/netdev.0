From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 4/6] qlge: Fix possible endian issue for rx UDP csum.
Date: Mon,  5 Jul 2010 15:19:40 -0700
Message-ID: <1278368382-23887-5-git-send-email-ron.mercer@qlogic.com>
References: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:42713 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755009Ab0GEXFR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 19:05:17 -0400
In-Reply-To: <1278368382-23887-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index e39451b..a41b6b5 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1677,7 +1677,7 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 			/* Unfragmented ipv4 UDP frame. */
 			struct iphdr *iph = (struct iphdr *) skb->data;
 			if (!(iph->frag_off &
-				cpu_to_be16(IP_MF|IP_OFFSET))) {
+				ntohs(IP_MF|IP_OFFSET))) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				netif_printk(qdev, rx_status, KERN_DEBUG,
 					     qdev->ndev,
@@ -1997,7 +1997,7 @@ static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 		/* Unfragmented ipv4 UDP frame. */
 			struct iphdr *iph = (struct iphdr *) skb->data;
 			if (!(iph->frag_off &
-				cpu_to_be16(IP_MF|IP_OFFSET))) {
+				ntohs(IP_MF|IP_OFFSET))) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 				netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
 					     "TCP checksum done!\n");
-- 
1.6.0.2

