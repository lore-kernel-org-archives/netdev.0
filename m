From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ip: fix warning in xfrm4_mode_tunnel_input
Date: Sat, 16 Feb 2013 09:40:29 -0800
Message-ID: <20130216094029.4d2fc993@nehalam.linuxnetplumber.net>
References: <20130216093815.45e2d8b2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33632 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514Ab3BPRkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 12:40:47 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so2183600pad.10
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2013 09:40:46 -0800 (PST)
In-Reply-To: <20130216093815.45e2d8b2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same problem as IPv6

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv4/xfrm4_mode_tunnel.c	2013-02-16 09:09:41.388937316 -0800
+++ b/net/ipv4/xfrm4_mode_tunnel.c	2013-02-16 09:39:21.849910500 -0800
@@ -142,7 +142,8 @@ static int xfrm4_mode_tunnel_input(struc
 	for_each_input_rcu(rcv_notify_handlers, handler)
 		handler->handler(skb);
 
-	if (err = skb_unclone(skb, GFP_ATOMIC))
+	err = skb_unclone(skb, GFP_ATOMIC);
+	if (err)
 		goto out;
 
 	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
