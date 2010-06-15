From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] netdev:bfin_mac: reclaim and free tx skb as soon as
 possible after transfer
Date: Tue, 15 Jun 2010 15:04:27 -0700 (PDT)
Message-ID: <20100615.150427.27816860.davem@davemloft.net>
References: <1276250702.30044.2.camel@eight.analog.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39497
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754353Ab0FOWEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 18:04:16 -0400
In-Reply-To: <1276250702.30044.2.camel@eight.analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sonic zhang <sonic.adi@gmail.com>
Date: Fri, 11 Jun 2010 18:05:02 +0800

>>From 4779e43a5a8446f695f8d6f5a006cfb45dc093d8 Mon Sep 17 00:00:00 2001
> From: Sonic Zhang <sonic.zhang@analog.com>
> Date: Fri, 11 Jun 2010 17:44:31 +0800
> Subject: [PATCH v4] netdev:bfin_mac: reclaim and free tx skb as soon as possible after transfer
> 
> SKBs hold onto resources that can't be held indefinitely, such as TCP
> socket references and netfilter conntrack state.  So if a packet is left
> in TX ring for a long time, there might be a TCP socket that cannot be
> closed and freed up.
> 
> Current blackfin EMAC driver always reclaim and free used tx skbs in future
> transfers. The problem is that future transfer may not come as soon as
> possible. This patch start a timer after transfer to reclaim and free skb.
> There is nearly no performance drop with this patch.
> 
> TX interrupt is not enabled because of a strange behavior of the Blackfin EMAC.
> If EMAC TX transfer control is turned on, endless TX interrupts are triggered
> no matter if TX DMA is enabled or not. Since DMA walks down the ring automatically,
> TX transfer control can't be turned off in the middle. The only way is to disable
> TX interrupt completely.
> 
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>

Applied to net-next-2.6, thanks.
