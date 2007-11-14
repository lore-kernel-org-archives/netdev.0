From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: skb processing in SMP kernel
Date: Wed, 14 Nov 2007 12:34:40 -0800
Message-ID: <20071114123440.0fa0031d@freepuppy.rosehill>
References: <20071114211437.7f4c79d2@catlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marek Kierdelewicz <marek@koba.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48339 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754543AbXKNUgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 15:36:18 -0500
In-Reply-To: <20071114211437.7f4c79d2@catlap>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Nov 2007 21:14:37 +0100
Marek Kierdelewicz <marek@koba.pl> wrote:

> Hi there,
> 
> I'm looking at file /usr/src/linux/net/core/dev.c
> function "int netif_rx(struct sk_buff *skb)"
> and following line:
>  
> queue = &__get_cpu_var(softnet_data);
> 
> Is it possible to put skb into the queue of another CPU then the one
> servicing the interrupt? (Disclaimer: Yeah, I know it's probably not
> the smartest thing to do because of locks and cache line bounces). How
> could it be accomplished? Any lead, comment, link appreciated.
> 
> 
> pozdrawiam

You could but then you would need locking on the queue, and that would
defeat the whole purpose of per-cpu queue's.  You would also need to do
an IPI to notify the other processor.

If you are trying to do packet distribution, look at the newest drivers that use MSI-X
and napi to do packet distribution.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
