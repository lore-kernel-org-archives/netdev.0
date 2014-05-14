From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] loopback: explicitly set pkt_type to PACKET_HOST
Date: Wed, 14 May 2014 11:39:22 -0700
Message-ID: <1400092762-23287-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33934 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbaENSjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 14:39:33 -0400
Received: by mail-pa0-f41.google.com with SMTP id lj1so2017646pab.0
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 11:39:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

In a corner case where I redirect the packets from veth to lo,
packets are dropped silently when entering IP stack. This is
due to we have a different MAC addr on veth, so the packets are
marked as PACKET_OTHERHOST. And after they are redirect to lo,
this value is kept since lo has the same MAC addr with the packets.
Loopback should explicitly set it to PACKET_HOST before calling
eth_type_trans() for this specific case.

Cc: David S. Miller <davem@davemloft.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>

---
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index bb96409..52b6625 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -81,6 +81,7 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 	 */
 	skb_dst_force(skb);
 
+	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
