From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/3] qeth: Convert use of __constant_htons to htons
Date: Wed, 19 Aug 2015 10:20:53 +0200
Message-ID: <1439972454-64347-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1439972454-64347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Vaishali Thakkar <vthakkar1994@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:53769 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbbHSIVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 04:21:09 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 19 Aug 2015 09:21:08 +0100
In-Reply-To: <1439972454-64347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vaishali Thakkar <vthakkar1994@gmail.com>

In little endian cases, the macro htons unfolds to __swab16 which
provides special case for constants. In big endian cases,
__constant_htons and htons expand directly to the same expression.
So, replace __constant_htons with htons with the goal of getting
rid of the definition of __constant_htons completely.

The semantic patch that performs this transformation is as follows:

@@expression x;@@

- __constant_htons(x)
+ htons(x)

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 2 +-
 drivers/s390/net/qeth_l3_main.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index e0f0188..dce1538 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -272,7 +272,7 @@ static void qeth_l2_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 	/* VSWITCH relies on the VLAN
 	 * information to be present in
 	 * the QDIO header */
-	if (veth->h_vlan_proto == __constant_htons(ETH_P_8021Q)) {
+	if (veth->h_vlan_proto == htons(ETH_P_8021Q)) {
 		hdr->hdr.l2.flags[2] |= QETH_LAYER2_FLAG_VLAN;
 		hdr->hdr.l2.vlan_id = ntohs(veth->h_vlan_TCI);
 	}
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 70eb2f6..ecfe622 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1887,13 +1887,13 @@ static inline int qeth_l3_rebuild_skb(struct qeth_card *card,
 		case QETH_CAST_MULTICAST:
 			switch (prot) {
 #ifdef CONFIG_QETH_IPV6
-			case __constant_htons(ETH_P_IPV6):
+			case htons(ETH_P_IPV6):
 				ndisc_mc_map((struct in6_addr *)
 				     skb->data + 24,
 				     tg_addr, card->dev, 0);
 				break;
 #endif
-			case __constant_htons(ETH_P_IP):
+			case htons(ETH_P_IP):
 				ip_hdr = (struct iphdr *)skb->data;
 				ip_eth_mc_map(ip_hdr->daddr, tg_addr);
 				break;
-- 
2.3.8
