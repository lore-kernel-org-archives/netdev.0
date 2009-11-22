From: Patrick McHardy <kaber@trash.net>
Subject: Re: Bridge + Conntrack + SKB Recycle: Fragment Reassembly Errors
Date: Sun, 22 Nov 2009 01:29:52 +0100
Message-ID: <4B088600.8090209@trash.net>
References: <767BAF49E93AFB4B815B11325788A8ED45F0BA@L01SLCXDB03.calltower.com>	<4AF999DE.9060206@trash.net> <20091121.110832.213888237.davem@davemloft.net> <4B0883FD.2090806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070006080406090204090807"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: ben@bigfootnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36731 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbZKVA3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 19:29:48 -0500
In-Reply-To: <4B0883FD.2090806@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070006080406090204090807
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> So it seems we need to adjust skb->truesize in ip_fragment() since
> skb_recycle_check() assumes the skb is linear (and therefore
> skb->truesize reflects the linear size). Ben's suggestions of adding
> an upper limit based on the requested size to skb_recycle_check()
> makes sense to me as well to avoid this problem when recycling large
> linear skbs.

Ben, please give this patch a try.

--------------070006080406090204090807
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 322b408..031989d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -501,8 +501,8 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			if (skb->sk) {
 				frag->sk = skb->sk;
 				frag->destructor = sock_wfree;
-				truesizes += frag->truesize;
 			}
+			truesizes += frag->truesize;
 		}
 
 		/* Everything is OK. Generate! */

--------------070006080406090204090807--
