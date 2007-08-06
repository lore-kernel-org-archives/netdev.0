From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.22-rc7] xfrm beet interfamily support
Date: Mon, 06 Aug 2007 14:08:12 +0200
Message-ID: <46B70F2C.6090807@trash.net>
References: <200707161506.47915.joakim.koskela@hiit.fi> <469BBD4C.5040503@trash.net> <200707171730.21655.joakim.koskela@hiit.fi> <200708060949.58758.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joakim Koskela <joakim.koskela@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37116 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbXHFMIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 08:08:30 -0400
In-Reply-To: <200708060949.58758.joakim.koskela@hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Koskela wrote:
> On Tuesday 17 July 2007 17:30:21 Joakim Koskela wrote:
> 
>>>>@@ -108,7 +108,8 @@ int xfrm4_rcv_encap(struct sk_buff *skb, __u16
>>>>encap_type) if (x->mode->input(x, skb))
>>>> 			goto drop;
>>>>
>>>>-		if (x->props.mode == XFRM_MODE_TUNNEL) {
>>>>+		if (x->props.mode == XFRM_MODE_TUNNEL ||
>>>>+		    x->props.mode == XFRM_MODE_BEET) {
>>>> 			decaps = 1;
>>>> 			break;
>>>> 		}
>>>
> It's been a while, but as a fyi in case there are comments / suggestions 
> before submitting the whole patch again - it seems that this had some 
> problems after all. Works ok for normal cases, but fails when using ip 
> options for the inner packet as they don't get processed after being 
> extracted from the pseudoheader. Calling something like ip_options_compile 
> from beet_mode's input when handling ipv4 would do the trick, but seems a bit 
> ugly & perhaps unsafe, I'd rather just put the whole packet through the loop 
> again.


Won't the options get parsed by ip_rcv() on the second reception?
