From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bnx2x: use the default NAPI weight
Date: Tue, 05 Mar 2013 23:37:44 -0500 (EST)
Message-ID: <20130305.233744.498353801662910535.davem@davemloft.net>
References: <1362535067.15793.146.camel@edumazet-glaptop>
	<20130305.210909.1826827522208936437.davem@davemloft.net>
	<1362540509.15793.158.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354Ab3CFEhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:37:45 -0500
In-Reply-To: <1362540509.15793.158.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Mar 2013 19:28:29 -0800

> We are facing a fanout/fanin problem for a given application.
> 
> What happens is that link is mostly idle, and every couple of minutes,
> we receive a burst of messages, needing a burst of transmits.
> 
> BQL starts with a limit of 0, meaning it needs some TX completion runs
> to be able to detect the sudden increase of TX need and reach line rate.
> 
> bnx2x is really unfair in this scenario, because the NAPI poll budget is
> very high, and aggregated packets (by LRO) count for a single packet in
> the budget. (or even 0, see the "goto next_cqe;" that avoids the rx_pkt
> ++; in drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c line 1007)
> 
> We probably have other issues in the stack, I am patiently finding all
> of them. In the mean time we had to disable BQL :(

Thanks for the explanation.

Since you haven't completely resolved the issues you were running into
I'll target this to net-next for now.

Thanks!
