From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 8/8] qlcnic: Set skb->csum_level for encapsulated
 checksum
Date: Mon, 25 Aug 2014 17:56:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408251737500.5508@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f202.google.com ([209.85.160.202]:49026 "EHLO
	mail-yk0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZBXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 21:23:30 -0400
Received: by mail-yk0-f202.google.com with SMTP id q9so1670475ykb.5
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 18:23:30 -0700 (PDT)
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
