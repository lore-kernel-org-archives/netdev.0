From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] net: neighbour: use source address of last
 enqueued packet for solicitation
Date: Thu, 26 Sep 2013 13:46:55 -0400 (EDT)
Message-ID: <20130926.134655.889702001911014781.davem@redhat.com>
References: <20130921043234.GA13307@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690Ab3IZRrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 13:47:07 -0400
In-Reply-To: <20130921043234.GA13307@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 21 Sep 2013 06:32:34 +0200

> Currently we always use the first member of the arp_queue to determine
> the sender ip address of the arp packet (or in case of IPv6 - source
> address of the ndisc packet). This skb is fixed as long as the queue is
> not drained by a complete purge because of a timeout or by a successful
> response.
> 
> If the first packet enqueued on the arp_queue is from a local application
> with a manually set source address and the to be discovered system
> does some kind of uRPF checks on the source address in the arp packet
> the resolving process hangs until a timeout and restarts. This hurts
> communication with the participating network node.
> 
> This could be mitigated a bit if we use the latest enqueued skb's
> source address for the resolving process, which is not as static as
> the arp_queue's head. This change of the source address could result in
> better recovery of a failed solicitation.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Julian Anastasov <ja@ssi.bg>
> Reviewed-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, but honestly I think the tail packet has just as much chance
to come from an application with a manually set source address as
the head one.
