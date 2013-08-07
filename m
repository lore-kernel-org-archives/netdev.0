From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: cubic: fix bug in bictcp_acked()
Date: Wed, 07 Aug 2013 10:37:02 -0700 (PDT)
Message-ID: <20130807.103702.2279717727976902224.davem@davemloft.net>
References: <1375758312.4457.69.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, vanj@google.com,
	ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757235Ab3HGRbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 13:31:47 -0400
In-Reply-To: <1375758312.4457.69.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 05 Aug 2013 20:05:12 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While investigating about strange increase of retransmit rates
> on hosts ~24 days after boot, Van found hystart was disabled
> if ca->epoch_start was 0, as following condition is true
> when tcp_time_stamp high order bit is set.
> 
> (s32)(tcp_time_stamp - ca->epoch_start) < HZ
> 
> Quoting Van :
> 
>  At initialization & after every loss ca->epoch_start is set to zero so
>  I believe that the above line will turn off hystart as soon as the 2^31
>  bit is set in tcp_time_stamp & hystart will stay off for 24 days.
>  I think we've observed that cubic's restart is too aggressive without
>  hystart so this might account for the higher drop rate we observe.
> 
> Diagnosed-by: Van Jacobson <vanj@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
