From: Chonggang Li <chonggangli@google.com>
Subject: [PATCH net-next] bonding: do not pass link-local packets to master-interface
Date: Fri, 14 Apr 2017 11:00:22 -0700
Message-ID: <20170414180022.124453-1-chonggangli@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Chonggang Li <chonggangli@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
        nikolay@redhat.com, edumazet@google.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35727 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdDNSAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 14:00:43 -0400
Received: by mail-pf0-f178.google.com with SMTP id i5so43224437pfc.2
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 11:00:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously link-local packets excluding LACP (which are handled by
the recv_probe) received on bond slave interfaces are delivered to
stack with bond-master device with RX_HANDLER_ANOTHER, however all
link-local packets are link specific and should be delivered with
exact same link/dev.

Signed-off-by: Chonggang Li <chonggangli@google.com>
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 drivers/net/bonding/bond_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 01e4a69af421..aeca3d8541b9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1176,6 +1176,9 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 		}
 	}
 
+	/* link-local packets should not be passed to master interface */
+	if (is_link_local_ether_addr(eth_hdr(skb)->h_dest))
+		return RX_HANDLER_PASS;
 	if (bond_should_deliver_exact_match(skb, slave, bond))
 		return RX_HANDLER_EXACT;
 
-- 
2.12.2.762.g0e3151a226-goog
