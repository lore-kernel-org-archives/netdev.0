From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: Fix a DMA-API error handling warning
Date: Wed, 19 Jun 2013 22:18:15 -0700 (PDT)
Message-ID: <20130619.221815.1630968197223302672.davem@davemloft.net>
References: <1371576808-21907-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lkundrak@v3.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371576808-21907-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lubomir Rintel <lkundrak@v3.sk>
Date: Tue, 18 Jun 2013 19:33:28 +0200

> We check the failure status just prior to unmap, since it would be too much of
> a hassle to roll back commands we already started to enqueue if we handled it
> just after the map.
> 
> This way we at least avoid a lockup on reclaim, the card presumably didn't
> succeed DMA-ing to a bogus address anyway.

You have to handle it at map time, I don't care how complicated it is.

As is, when a DMA mapping failure occurs the chip is crapping into
random memory.  At that point, who cares what you decide to do about
it at unmap time?

This patch is unacceptable, sorry.
