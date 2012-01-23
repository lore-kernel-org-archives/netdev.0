From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix ipv6 header length computation
Date: Mon, 23 Jan 2012 14:25:50 -0500 (EST)
Message-ID: <20120123.142550.882140949914528850.davem@davemloft.net>
References: <1327317729.2525.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753779Ab2AWTZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 14:25:55 -0500
In-Reply-To: <1327317729.2525.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Jan 2012 12:22:09 +0100

> tg3_start_xmit() makes the wrong assumption for TSOV6 that skb->head
> doesnt include any payload data.
> 
> if (skb_is_gso_v6(skb))
> 	hdr_len = skb_headlen(skb) - ETH_HLEN;
> 
> This is not true anymore after commit f07d960df3 (tcp: avoid frag
> allocation for small frames)
> 
> We should instead use : skb_transport_offset(skb) + tcp_hdrlen(skb)
> 
> Its also true for IPv4
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Matt Carlson <mcarlson@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> ---
> I dont have a compatable hardware (5755_PLUS ?) so please guys test
> this...

I've applied this, if testing finds problems we can fix it up or revert.
