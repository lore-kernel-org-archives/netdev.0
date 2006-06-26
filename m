From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Mon, 26 Jun 2006 20:24:04 +0200
Message-ID: <44A02644.6020200@trash.net>
References: <20060626145446.948105000@postel.suug.ch>	<20060626145515.769648000@postel.suug.ch>	<44A0138F.8050208@trash.net> <20060626.104654.98552111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48052 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932616AbWFZSYG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 14:24:06 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060626.104654.98552111.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 26 Jun 2006 19:04:15 +0200
> 
> 
>>I know this was discussed before, but I can't remember the
>>exact outcome. Why don't we just unconditionally update iif
>>in netif_receive_skb()?
> 
> 
> Software devices might have interesting semantics that would
> make not setting iif desirable.

Right, I remember now.

> Once you set iif, you can't just undo it because the information
> is lost.
> 
> I also would really prefer to set it unconditionally in
> netif_receive_skb(), but Jamal's concerns in this area are real.
> We really need to evaluate this on a case-by-case basis.

I still have a hard time imagining a case where this wouldn't fit,
netfilter is perfectly happy with just using skb->dev as input
device on the input path so far. I also think it will be confusing
to the user to have different notions of what constitutes the input
device. If anyone can think of an example where the user would
really expect the input device to be something different than
skb->dev I'd be really interested to hear it.

BTW, this is not meant to be an objection to Thomas's patch, just
me still wondering ..

