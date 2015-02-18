From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v5 1/6] bonding: Verify RX LACPDU has proper dest mac-addr
Date: Wed, 18 Feb 2015 14:31:19 -0800
Message-ID: <1424298679-18186-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:33266 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbbBRWbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 17:31:24 -0500
Received: by pdbfl12 with SMTP id fl12so1479496pdb.0
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 14:31:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 802.1AX standard states:
"The DA in LACPDUs is the Slow_Protocols_Multicast address."

This patch enforces that and drops LACPDUs with destination MAC
addresses other than Slow_Protocols_Multicast address

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v1:
   Initial version
v2-v5:
   Rebase

 drivers/net/bonding/bond_3ad.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index cfc4a9c1000a..9b436696b95e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2485,6 +2485,9 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 	if (skb->protocol != PKT_TYPE_LACPDU)
 		return RX_HANDLER_ANOTHER;
 
+	if (!MAC_ADDRESS_EQUAL(eth_hdr(skb)->h_dest, lacpdu_mcast_addr))
+		return RX_HANDLER_ANOTHER;
+
 	lacpdu = skb_header_pointer(skb, 0, sizeof(_lacpdu), &_lacpdu);
 	if (!lacpdu)
 		return RX_HANDLER_ANOTHER;
-- 
2.2.0.rc0.207.ga3a616c
