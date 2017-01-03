From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: vrf: Add missing Rx counters
Date: Tue,  3 Jan 2017 09:37:55 -0800
Message-ID: <1483465075-15452-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35476 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935525AbdACRjN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 12:39:13 -0500
Received: by mail-pf0-f180.google.com with SMTP id i88so77576387pfk.2
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 09:38:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The move from rx-handler to L3 receive handler inadvertantly dropped the
rx counters. Restore them.

Fixes: 74b20582ac38 ("net: l3mdev: Add hook in ip and ipv6")
Reported-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 7532646c3b7b..23dfb0eac098 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -967,6 +967,7 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
 	 */
 	need_strict = rt6_need_strict(&ipv6_hdr(skb)->daddr);
 	if (!ipv6_ndisc_frame(skb) && !need_strict) {
+		vrf_rx_stats(vrf_dev, skb->len);
 		skb->dev = vrf_dev;
 		skb->skb_iif = vrf_dev->ifindex;
 
@@ -1011,6 +1012,8 @@ static struct sk_buff *vrf_ip_rcv(struct net_device *vrf_dev,
 		goto out;
 	}
 
+	vrf_rx_stats(vrf_dev, skb->len);
+
 	skb_push(skb, skb->mac_len);
 	dev_queue_xmit_nit(skb, vrf_dev);
 	skb_pull(skb, skb->mac_len);
-- 
2.1.4
