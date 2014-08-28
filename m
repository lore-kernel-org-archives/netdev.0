From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 9/9] qlcnic: Set skb->csum_level for encapsulated
 checksum
Date: Wed, 27 Aug 2014 21:28:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408272111550.32740@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:35614 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbaH1Efg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 00:35:36 -0400
Received: by mail-ob0-f202.google.com with SMTP id wp18so214495obc.3
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 21:35:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set skb->csum_level instead of skb->encapsulation when indicating
CHECKSUM_UNNECESSARY for an encapsulated checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index e45bf09..18e5de7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1753,7 +1753,7 @@ qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
 
 	if (qlcnic_encap_length(sts_data[1]) &&
 	    skb->ip_summed == CHECKSUM_UNNECESSARY) {
-		skb->encapsulation = 1;
+		skb->csum_level = 1;
 		adapter->stats.encap_rx_csummed++;
 	}
 
-- 
2.1.0.rc2.206.gedb03e5
