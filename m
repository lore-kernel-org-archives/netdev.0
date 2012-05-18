From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Fri, 18 May 2012 06:41:06 +0200
Message-ID: <1337316066.3403.76.camel@edumazet-glaptop>
References: <20120517164016.GL14498@1wt.eu>
	 <1337273387.3403.24.camel@edumazet-glaptop>
	 <1337276056.3403.37.camel@edumazet-glaptop>
	 <20120517.155318.1557653193070030300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41705 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756204Ab2ERElL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 00:41:11 -0400
Received: by weyu7 with SMTP id u7so1563648wey.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 21:41:10 -0700 (PDT)
In-Reply-To: <20120517.155318.1557653193070030300.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 15:53 -0400, David Miller wrote:

> Applied, we can sort out any fallout very easily before 3.5 is released.
> 
> Awesome work Eric.

Thanks David

I'll send a followup patch to fix issues :

- Must be IRQ safe (non NAPI drivers can use it)
- Must not leak the frag is build_skb() fails to allocate sk_buff

- Factorize code so that dev_alloc_skb()/__dev_alloc_skb() are a wrapper
around __netdev_alloc_skb()
