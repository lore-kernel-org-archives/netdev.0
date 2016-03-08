From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/1] qede: Fix net-next "make ARCH=x86_64"
Date: Tue, 8 Mar 2016 04:09:44 -0500
Message-ID: <1457428184-18336-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:63642 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932420AbcCHJuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 04:50:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'commit 55482edc25f0606851de42e73618f813f310d009
("qede: Add slowpath/fastpath support and enable hardware GRO")'
introduces below error when compiling net-next with "make ARCH=x86_64"

drivers/built-in.o: In function `qede_rx_int':
qede_main.c:(.text+0x6101a0): undefined reference to `tcp_gro_complete'

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 5728625..518af32 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1001,6 +1001,7 @@ static void qede_tpa_start(struct qede_dev *edev,
 	}
 }
 
+#ifdef CONFIG_INET
 static void qede_gro_ip_csum(struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -1029,12 +1030,14 @@ static void qede_gro_ipv6_csum(struct sk_buff *skb)
 				  &iph->saddr, &iph->daddr, 0);
 	tcp_gro_complete(skb);
 }
+#endif
 
 static void qede_gro_receive(struct qede_dev *edev,
 			     struct qede_fastpath *fp,
 			     struct sk_buff *skb,
 			     u16 vlan_tag)
 {
+#ifdef CONFIG_INET
 	if (skb_shinfo(skb)->gso_size) {
 		switch (skb->protocol) {
 		case htons(ETH_P_IP):
@@ -1049,7 +1052,7 @@ static void qede_gro_receive(struct qede_dev *edev,
 			       ntohs(skb->protocol));
 		}
 	}
-
+#endif
 	skb_record_rx_queue(skb, fp->rss_id);
 	qede_skb_receive(edev, fp, skb, vlan_tag);
 }
-- 
2.7.2
