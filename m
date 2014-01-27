From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 27 Jan 2014 12:57:46 -0800 (PST)
Message-ID: <20140127.125746.15766634214020447.davem@davemloft.net>
References: <1390845492-18780-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36547 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875AbaA0U5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 15:57:49 -0500
In-Reply-To: <1390845492-18780-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 27 Jan 2014 18:58:12 +0100

> Marcelo Ricardo Leitner reported problems when the forwarding link
> path has a lower mtu than the incoming link if the inbound interface
> supports GRO.
> 
> Given:
> Host <mtu1500> R1 <mtu1200> R2
> 
> Host sends tcp stream which is routed via R1 and R2.  R1 performs GRO.
> 
> In this case, the kernel will fail to send ICMP fragmentation needed
> messages (or pkt too big for ipv6), as gso packets currently bypass the
> dst mtu checks in forward path. Instead, Linux tries to send out packets
> exceeding R1-R2 link mtu.
> 
> When locking route MTU on Host (i.e., no ipv4 DF bit set), R1 does
> not fragment the packets when forwarding, and again tries to send out
> packets exceeding R1-R2 link mtu.
> 
> This alters the forwarding dstmtu checks to take the individual gso
> segment lengths into account.
> 
> For ipv6, we send out pkt too big error for gso if the individual
> segments are too big.
> 
> For ipv4, we either send icmp fragmentation needed, or, if the DF bit
> is not set, perform software segmentation and let the output path
> create fragments when the packet is leaving the machine.
> It is not 100% correct as the error message will contain the headers of
> the GRO skb instead of the original/segmented one, but it seems to
> work fine in my (limited) tests.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks.
