From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net-gro: reset skb->truesize in napi_reuse_skb()
Date: Thu, 03 Apr 2014 16:18:34 -0400 (EDT)
Message-ID: <20140403.161834.1232262926542795326.davem@davemloft.net>
References: <1396542490.12330.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbaDCURA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 16:17:00 -0400
In-Reply-To: <1396542490.12330.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Apr 2014 09:28:10 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Recycling skb always had been very tough...
> 
> This time it appears GRO layer can accumulate skb->truesize
> adjustments made by drivers when they attach a fragment to skb.
> 
> skb_gro_receive() can only subtract from skb->truesize the used part
> of a fragment.
> 
> I spotted this problem seeing TcpExtPruneCalled and
> TcpExtTCPRcvCollapsed that were unexpected with a recent kernel, where
> TCP receive window should be sized properly to accept traffic coming
> from a driver not overshooting skb->truesize.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Nasty...

Applied, thanks Eric.
