From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 03/12] bonding: always update last_arp_rx on packet recieve
Date: Fri, 17 Jan 2014 17:58:51 +0100
Message-ID: <1389977940-17084-4-git-send-email-vfalico@redhat.com>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbaAQREQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:04:16 -0500
In-Reply-To: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
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
index cc30618..909f164 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2289,6 +2289,8 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	__be32 sip, tip;
 	int alen;
 
+	slave->last_arp_rx = jiffies;
+
 	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
 		return RX_HANDLER_ANOTHER;
 
-- 
1.8.4
