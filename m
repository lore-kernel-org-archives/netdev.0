From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ipv6: fix warning in xfrm6_mode_tunnel_input
Date: Sat, 16 Feb 2013 09:38:15 -0800
Message-ID: <20130216093815.45e2d8b2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:57972 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710Ab3BPRie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 12:38:34 -0500
Received: by mail-pb0-f54.google.com with SMTP id rr4so1051439pbb.41
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2013 09:38:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should not use assignment in conditional:
 warning: suggest parentheses around assignment used as truth value [-Wparentheses]

Problem introduced by:
commit 14bbd6a565e1bcdc240d44687edb93f721cfdf99
Author: Pravin B Shelar <pshelar@nicira.com>
Date:   Thu Feb 14 09:44:49 2013 +0000

    net: Add skb_unclone() helper function.
    

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv6/xfrm6_mode_tunnel.c	2013-02-16 09:09:41.388937316 -0800
+++ b/net/ipv6/xfrm6_mode_tunnel.c	2013-02-16 09:33:49.906203566 -0800
@@ -69,7 +69,8 @@ static int xfrm6_mode_tunnel_input(struc
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
 		goto out;
 
-	if (err = skb_unclone(skb, GFP_ATOMIC))
+	err = skb_unclone(skb, GFP_ATOMIC);
+	if (err)
 		goto out;
 
 	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
