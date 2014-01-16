From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/6] bonding: always update last_arp_rx on arp recieve
Date: Thu, 16 Jan 2014 03:05:11 +0100
Message-ID: <1389837916-5377-2-git-send-email-vfalico@redhat.com>
References: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181AbaAPCJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 21:09:34 -0500
In-Reply-To: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're updating the last_arp_rx only when we've validate the
packet, however afterwards we use it as 'ANY last arp received', but not
only validated ARPs.

Fix this by updating it even if the slave doesn't require arp validation.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f2fe6cb..cfb37af 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2294,8 +2294,10 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 
 	read_lock(&bond->lock);
 
-	if (!slave_do_arp_validate(bond, slave))
+	if (!slave_do_arp_validate(bond, slave)) {
+		slave->last_arp_rx = jiffies;
 		goto out_unlock;
+	}
 
 	alen = arp_hdr_len(bond->dev);
 
-- 
1.8.4
