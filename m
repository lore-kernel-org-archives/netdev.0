From: Peter Heise <mail@pheise.de>
Subject: [PATCH net v2] Check for skb_put_padto return value
Date: Sun, 7 May 2017 17:15:26 +0000
Message-ID: <0102015be3e8a656-6cd75d31-ac07-4255-80d9-3c481165dfaa-000000@eu-west-1.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mail@pheise.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a4-23.smtp-out.eu-west-1.amazonses.com ([54.240.4.23]:58170
        "EHLO a4-23.smtp-out.eu-west-1.amazonses.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751733AbdEGVmb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 17:42:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return value of skb_put_padto is now checked as
reported by Dan Carpenter. skb might be freed in
case of error in skb_put_padto.
---
 net/hsr/hsr_device.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index c73160fb11e7..a1545d09a3c9 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -314,7 +314,8 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
 	hsr_sp = (typeof(hsr_sp)) skb_put(skb, sizeof(struct hsr_sup_payload));
 	ether_addr_copy(hsr_sp->MacAddressA, master->dev->dev_addr);
 
-	skb_put_padto(skb, ETH_ZLEN + HSR_HLEN);
+	if (skb_put_padto(skb, ETH_ZLEN + HSR_HLEN))
+		return;
 
 	hsr_forward_skb(skb, master);
 	return;
-- 
2.11.0
