From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 03/12] bonding: always update last_arp_rx on packet recieve
Date: Mon, 17 Feb 2014 15:41:19 +0100
Message-ID: <1392648088-21336-4-git-send-email-vfalico@redhat.com>
References: <1392648088-21336-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22682 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753619AbaBQOpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 09:45:54 -0500
In-Reply-To: <1392648088-21336-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're updating the last_arp_rx only when we've validate the
packet, however afterwards we use it as 'ANY last packet received', but not
only validated ARPs.

Fix this by updating it in case of any packet received. It won't break the
arp_validation=0 because we, anyway, return the correct slave->dev->last_rx in
slave_last_rx().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 91c0248..7747cc5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2257,6 +2257,8 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	__be32 sip, tip;
 	int alen;
 
+	slave->last_arp_rx = jiffies;
+
 	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
 		return RX_HANDLER_ANOTHER;
 
-- 
1.8.4
