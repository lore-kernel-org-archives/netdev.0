From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: fix state transition INCOMPLETE->FAILED via
 Netlink request
Date: Thu, 11 Jun 2009 04:16:45 -0700 (PDT)
Message-ID: <20090611.041645.160293472.davem@davemloft.net>
References: <20090611.031215.17106793.davem@davemloft.net>
	<1244716345-9407-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52716
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755863AbZFKLQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 07:16:43 -0400
In-Reply-To: <1244716345-9407-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Thu, 11 Jun 2009 13:32:25 +0300

> The current code errors out the INCOMPLETE neigh entry skb queue only from
> the timer if maximum probes have been attempted and there has been no reply.
> This also causes the transtion to FAILED state.
> 
> However, the neigh entry can be also updated via Netlink to inform that the
> address is unavailable.  Currently, neigh_update() just stops the timers and
> leaves the pending skb's unreleased. This results that the clean up code in
> the timer callback is never called, preventing also proper garbage collection.
> 
> This fixes neigh_update() to process the pending skb queue immediately if
> INCOMPLETE -> FAILED state transtion occurs due to a Netlink request.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Looks great, applied, thanks!
