From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] unix: add read side socket memory accounting for dgram sockets
Date: Tue, 4 Mar 2014 21:13:36 +0100
Message-ID: <20140304201336.GB26307@order.stressinduktion.org>
References: <20140219200811.GE1179@order.stressinduktion.org> <20140226.145559.1040609936875578841.davem@davemloft.net> <20140226202154.GA9626@order.stressinduktion.org> <20140226.154232.1642777813885536970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yannick@koehler.name,
	eric.dumazet@gmail.com, xiyou.wangcong@gmail.com, dan@mindstab.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40117 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755263AbaCDUNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 15:13:37 -0500
Content-Disposition: inline
In-Reply-To: <20140226.154232.1642777813885536970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 26, 2014 at 03:42:32PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 26 Feb 2014 21:21:54 +0100
> 
> > On Wed, Feb 26, 2014 at 02:55:59PM -0500, David Miller wrote:
> >> I think you can safely put the 'other' sock pointer into the control
> >> block.  Because when we disassociate from a peer any pending packets
> >> in flight to him will be consumed/dropped, so there can't be any
> >> lingering references, right?
> > 
> > I am afraid lingering socket references will happen if the sockets are
> > used in unconnected mode.
> 
> Sigh...
> 
> Ok, let's wait for your hackbench results and work from there.

Just a small followup:

Because of the additional sock_wfree during skb handover in unix_dgram_sendmsg
the spinlock in __wake_up_sync_key is hit more often thus more cacheline
bouncing.

Deferring the POLLOUT notification after the sock_rfree in unix_dgram_recvmsg
already halfed the number of context switches with the new patch.

I try to play with some other ideas this week and will submit new patch with
performance numbers.

Haven't noticed any problems with the additional atomic operations
performance-wise so far.

Bye,

  Hannes
