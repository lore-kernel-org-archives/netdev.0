From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] filter: add SKF_AD_RXHASH and SKF_AD_CPU
Date: Mon, 06 Dec 2010 13:02:52 -0800 (PST)
Message-ID: <20101206.130252.232758553.davem@davemloft.net>
References: <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
	<1291176215.2856.383.camel@edumazet-laptop>
	<1291189556.2856.476.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wirelesser@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57684
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753211Ab0LFVCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:02:25 -0500
In-Reply-To: <1291189556.2856.476.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Dec 2010 08:45:56 +0100

> Add SKF_AD_RXHASH and SKF_AD_CPU to filter ancillary mechanism,
> to be able to build advanced filters.
> 
> This can help spreading packets on several sockets with a fast
> selection, after RPS dispatch to N cpus for example, or to catch a
> percentage of flows in one queue.
> 
> tcpdump -s 500 "cpu = 1" :
> 
> [0] ld CPU
> [1] jeq #1  jt 2  jf 3 
> [2] ret #500
> [3] ret #0
> 
> # take 12.5 % of flows (average)
> tcpdump -s 1000 "rxhash & 7 = 2" :
> 
> [0] ld RXHASH
> [1] and #7
> [2] jeq #2  jt 3  jf 4 
> [3] ret #1000
> [4] ret #0
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
