From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: cubic: fix overflow error in bictcp_update()
Date: Wed, 07 Aug 2013 10:36:30 -0700 (PDT)
Message-ID: <20130807.103630.161949444720355649.davem@davemloft.net>
References: <1375747815.4457.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, vanj@google.com,
	stephen@networkplumber.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757338Ab3HGRbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 13:31:22 -0400
In-Reply-To: <1375747815.4457.59.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Aug 2013 17:10:15 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 17a6e9f1aa9 ("tcp_cubic: fix clock dependency") added an
> overflow error in bictcp_update() in following code :
> 
> /* change the unit from HZ to bictcp_HZ */
> t = ((tcp_time_stamp + msecs_to_jiffies(ca->delay_min>>3) -
>       ca->epoch_start) << BICTCP_HZ) / HZ;
> 
> Because msecs_to_jiffies() being unsigned long, compiler does
> implicit type promotion.
> 
> We really want to constrain (tcp_time_stamp - ca->epoch_start)
> to a signed 32bit value, or else 't' has unexpected high values.
> 
> This bugs triggers an increase of retransmit rates ~24 days after
> boot [1], as the high order bit of tcp_time_stamp flips.
> 
> [1] for hosts with HZ=1000
> 
> Big thanks to Van Jacobson for spotting this problem.
> 
> Diagnosed-by: Van Jacobson <vanj@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
