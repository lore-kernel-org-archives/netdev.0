From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tsq: fix nonagle handling
Date: Mon, 10 Feb 2014 15:24:16 -0800 (PST)
Message-ID: <20140210.152416.1707361996340298057.davem@davemloft.net>
References: <1392000011.6615.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ogness@linutronix.de,
	thomas@glanzmann.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbaBJXYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 18:24:17 -0500
In-Reply-To: <1392000011.6615.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 Feb 2014 18:40:11 -0800

> From: John Ogness <john.ogness@linutronix.de>
> 
> Commit 46d3ceabd8d9 ("tcp: TCP Small Queues") introduced a possible
> regression for applications using TCP_NODELAY.
> 
> If TCP session is throttled because of tsq, we should consult
> tp->nonagle when TX completion is done and allow us to send additional
> segment, especially if this segment is not a full MSS.
> Otherwise this segment is sent after an RTO.
> 
> [edumazet] : Cooked the changelog, added another fix about testing
> sk_wmem_alloc twice because TX completion can happen right before
> setting TSQ_THROTTLED bit.
> 
> This problem is particularly visible with recent auto corking,
> but might also be triggered with low tcp_limit_output_bytes
> values or NIC drivers delaying TX completion by hundred of usec,
> and very low rtt.
> 
> Thomas Glanzmann for example reported an iscsi regression, caused
> by tcp auto corking making this bug quite visible.
> 
> Fixes: 46d3ceabd8d9 ("tcp: TCP Small Queues")
> Signed-off-by: John Ogness <john.ogness@linutronix.de>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Thomas Glanzmann <thomas@glanzmann.de>

Applied and queued up for -stable, thanks!
