From: Tom Herbert <therbert@google.com>
Subject: [PATCH net] gre: Set inner mac header in gro complete
Date: Sat, 29 Nov 2014 09:59:45 -0800
Message-ID: <1417283985-22269-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, linux@stwm.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:58562 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbaK2SDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 13:03:17 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn15so6971945igb.15
        for <netdev@vger.kernel.org>; Sat, 29 Nov 2014 10:03:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the inner mac header to point to the GRE payload when
doing GRO. This is needed if we proceed to send the packet
through GRE GSO which now uses the inner mac header instead
of inner network header to determine the length of encapsulation
headers.

Fixes: 14051f0452a2 ("gre: Use inner mac length when computing tunnel length")
Reported-by: Wolfgang Walter <linux@stwm.de>
Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/gre_offload.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index bb5947b..51973dd 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -247,6 +247,9 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 		err = ptype->callbacks.gro_complete(skb, nhoff + grehlen);
 
 	rcu_read_unlock();
+
+	skb_set_inner_mac_header(skb, nhoff + grehlen);
+
 	return err;
 }
 
-- 
2.2.0.rc0.207.ga3a616c
