From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH] tbf scheduler: TSO support (updated)
Date: Mon, 14 May 2007 01:21:25 +0900 (JST)
Message-ID: <20070514.012125.105712952.taka@valinux.co.jp>
References: <20070512.174930.80276554.taka@valinux.co.jp>
	<20070513.214236.130588832.taka@valinux.co.jp>
	<20070513085248.283bf060@mini>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	linux-net@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fms-01.valinux.co.jp ([210.128.90.1]:39969 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934272AbXEMQV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2007 12:21:28 -0400
In-Reply-To: <20070513085248.283bf060@mini>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > > I'm now thinking I can make it just hold a TSO packet until
> > > p->tokens reaches the size of the packet. I think it is
> > > straightforward implementation. I'll try this.
> > 
> > I re-implemented the patch, which is simpler than the previous one.
> > 
> > sch->dev->mtu is used to determine how many segments are included
> > in a TSO packet. The point is that the value of sch->dev->mtu has to
> > be treated possibly broken because it is set by administrators.
> >
> 
> There are cases where the TSO packet will be divided into chunks
> smaller than the MTU. If path MTU discovery is being used, the chunk
> size of the TSO skb will be smaller. To be accurate you need to look
> at mss (gso_size) and compute actual packet size based on protocol
> (IPV4/IPV6 and UDP/TCP).

Uhh, you are right.
skb_shinfo(skb)->gso_segs and skb_shinfo(skb)->gso_size should be used.
Thanks.
