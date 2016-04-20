From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net 2/3] qede: Fix setting Skb network header
Date: Wed, 20 Apr 2016 03:03:28 -0400
Message-ID: <1461135809-9776-3-git-send-email-manish.chopra@qlogic.com>
References: <1461135809-9776-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40657 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753643AbcDTHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 03:45:19 -0400
In-Reply-To: <1461135809-9776-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skb's network header needs to be set before extracting IPv4/IPv6
headers from it.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 5cf1eb2..bf0fb99 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1041,7 +1041,6 @@ static void qede_gro_ip_csum(struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct tcphdr *th;
 
-	skb_set_network_header(skb, 0);
 	skb_set_transport_header(skb, sizeof(struct iphdr));
 	th = tcp_hdr(skb);
 
@@ -1056,7 +1055,6 @@ static void qede_gro_ipv6_csum(struct sk_buff *skb)
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct tcphdr *th;
 
-	skb_set_network_header(skb, 0);
 	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
 	th = tcp_hdr(skb);
 
@@ -1073,6 +1071,8 @@ static void qede_gro_receive(struct qede_dev *edev,
 {
 #ifdef CONFIG_INET
 	if (skb_shinfo(skb)->gso_size) {
+		skb_set_network_header(skb, 0);
+
 		switch (skb->protocol) {
 		case htons(ETH_P_IP):
 			qede_gro_ip_csum(skb);
-- 
2.7.2
