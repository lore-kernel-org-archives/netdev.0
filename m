From: David Miller <davem@davemloft.net>
Subject: Re: Bridge + Conntrack + SKB Recycle: Fragment Reassembly Errors
Date: Sat, 21 Nov 2009 11:08:32 -0800 (PST)
Message-ID: <20091121.110832.213888237.davem@davemloft.net>
References: <767BAF49E93AFB4B815B11325788A8ED45F0BA@L01SLCXDB03.calltower.com>
	<4AF999DE.9060206@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@bigfootnetworks.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45539
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754271AbZKUTIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 14:08:14 -0500
In-Reply-To: <4AF999DE.9060206@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 10 Nov 2009 17:50:38 +0100

> This code in ip_fragment() looks suspicious:
> 
> 	if (skb_has_frags(skb)) {
> 	...
> 		skb_walk_frags(skb, frag) {
> 			...
> 			if (skb->sk) {
> 				frag->sk = skb->sk;
> 				frag->destructor = sock_wfree;
> 				truesizes += frag->truesize;
> 			}
> 
> truesizes is later used to adjust truesize of the head skb.
> For some reason this is only done when it originated from a
> local socket.

Well, it shouldn't look _that_ suspicious.

What this code is doing is making sure that after we make all of these
changes, the truesize of the SKBs referrng to the socket do not
change.

It's simply making sure that the math works out when all the
sock_wfree() calls occur later.

If we don't have a socket involved, there is no reason to make
these adjustments.
