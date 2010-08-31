From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 06/10] qlcnic: fix panic while using eth_hdr
Date: Tue, 31 Aug 2010 07:29:36 -0700
Message-ID: <1283264980-25881-7-git-send-email-amit.salecha@qlogic.com>
References: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:39191 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757389Ab0HaO3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 10:29:42 -0400
In-Reply-To: <1283264980-25881-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

o skb->mac_header is not set, so machine panics while using function eth_hdr.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 9a3ebb8..789fe81 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1991,6 +1991,7 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	struct qlcnic_skb_frag *buffrag;
 	struct cmd_desc_type0 *hwdesc, *first_desc;
 	struct pci_dev *pdev;
+	struct ethhdr *phdr;
 	int i, k;
 
 	u32 producer;
@@ -2003,7 +2004,8 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (adapter->flags & QLCNIC_MACSPOOF) {
-		if (compare_ether_addr(eth_hdr(skb)->h_source,
+		phdr = (struct ethhdr *)skb->data;
+		if (compare_ether_addr(phdr->h_source,
 					adapter->mac_addr))
 			goto drop_packet;
 	}
-- 
1.6.0.2

