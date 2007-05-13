From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] tbf scheduler: TSO support (updated)
Date: Sun, 13 May 2007 08:52:48 -0700
Message-ID: <20070513085248.283bf060@mini>
References: <20070511.130142.16832866.taka@valinux.co.jp>
	<4644B259.5060400@trash.net>
	<20070512.174930.80276554.taka@valinux.co.jp>
	<20070513.214236.130588832.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	linux-net@vger.kernel.org
To: Hirokazu Takahashi <taka@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.linux-foundation.org ([207.189.120.12]:43961 "EHLO
	smtp.osdl.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757745AbXEMQDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2007 12:03:11 -0400
In-Reply-To: <20070513.214236.130588832.taka@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 May 2007 21:42:36 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

> Hi,
> 
> > I'm now thinking I can make it just hold a TSO packet until
> > p->tokens reaches the size of the packet. I think it is
> > straightforward implementation. I'll try this.
> 
> I re-implemented the patch, which is simpler than the previous one.
> 
> sch->dev->mtu is used to determine how many segments are included
> in a TSO packet. The point is that the value of sch->dev->mtu has to
> be treated possibly broken because it is set by administrators.
>

There are cases where the TSO packet will be divided into chunks
smaller than the MTU. If path MTU discovery is being used, the chunk
size of the TSO skb will be smaller. To be accurate you need to look
at mss (gso_size) and compute actual packet size based on protocol
(IPV4/IPV6 and UDP/TCP).
