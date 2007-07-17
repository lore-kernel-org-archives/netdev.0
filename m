From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Tue, 17 Jul 2007 18:00:19 +0200
Message-ID: <469CE793.7020903@trash.net>
References: <200707161506.47915.joakim.koskela@hiit.fi> <469BBD4C.5040503@trash.net> <200707171730.21655.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: joakim.koskela@hiit.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47705 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752976AbXGQQA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 12:00:26 -0400
In-Reply-To: <200707171730.21655.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela wrote:
> On Monday 16 July 2007 21:47:40 Patrick McHardy wrote:
> 
>>>diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
>>>index 44ef208..8db7910 100644
>>>--- a/net/ipv4/xfrm4_output.c
>>>+++ b/net/ipv4/xfrm4_output.c
>>>@@ -53,7 +53,8 @@ static int xfrm4_output_one(struct sk_buff *skb)
>>> 			goto error_nolock;
>>> 	}
>>>
>>>-	if (x->props.mode == XFRM_MODE_TUNNEL) {
>>>+	if (x->props.mode == XFRM_MODE_TUNNEL ||
>>>+	    x->props.mode == XFRM_MODE_BEET) {
>>> 		err = xfrm4_tunnel_check_size(skb);
>>
>>Its not a real tunnel and all packets are generated locally, why
>>does it need to send ICMPs?
> 
> 
> Guess not. I'll have to still trace through, but can probably be removed.


Just FYI: it does make a difference with netfilter since packets
may be NATed to match a policy, but thats a more general problem
that also affects transport mode and should be dealt with within
netfilter, possibly by propagating PMTU values amonst dst_entries.

