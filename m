From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: shrink tcp6_timewait_sock by one cache
 line
Date: Thu, 03 Oct 2013 15:31:58 -0400 (EDT)
Message-ID: <20131003.153158.1558578931500427624.davem@davemloft.net>
References: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754728Ab3JCTcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:32:00 -0400
In-Reply-To: <1380711604.19002.78.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Oct 2013 04:00:04 -0700

> +	tmo = tw->tw_ttd - (u32)jiffies;
 ...
> +		tw->tw_ttd = (u32)(jiffies + timeo);
 ...
> +		tw->tw_ttd = (u32)(jiffies + (slot << INET_TWDR_RECYCLE_TICK));
 ...
> +	s32 delta = tw->tw_ttd - (u32)jiffies;
 ...
> +	s32 delta = tw->tw_ttd - (u32)jiffies;

Eric just use tcp_time_stamp in all of these locations, then you can
lose the casts and still achieve your stated objective.

Thanks.
