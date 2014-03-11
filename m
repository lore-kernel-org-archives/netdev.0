From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend] tcp: tcp_release_cb() should release socket
 ownership
Date: Tue, 11 Mar 2014 16:46:44 -0400 (EDT)
Message-ID: <20140311.164644.516273403169764933.davem@davemloft.net>
References: <20140304.134811.86791174090638790.davem@davemloft.net>
	<1393972752.26794.145.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394470211.3607.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755336AbaCKUqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:46:46 -0400
In-Reply-To: <1394470211.3607.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 10 Mar 2014 09:50:11 -0700

> Lars Persson reported following deadlock :
 ...
> Bug occurs because __tcp_checksum_complete_user() enables BH, assuming
> it is running from softirq context.
> 
> Lars trace involved a NIC without RX checksum support but other points
> are problematic as well, like the prequeue stuff.
> 
> Problem is triggered by a timer, that found socket being owned by user.
> 
> tcp_release_cb() should call tcp_write_timer_handler() or
> tcp_delack_timer_handler() in the appropriate context :
> 
> BH disabled and socket lock held, but 'owned' field cleared,
> as if they were running from timer handlers.
> 
> Fixes: 6f458dfb4092 ("tcp: improve latencies of timer triggered events")
> Reported-by: Lars Persson <lars.persson@axis.com>
> Tested-by: Lars Persson <lars.persson@axis.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks!
