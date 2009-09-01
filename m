From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/19] netdev: change transmit to limited range type
Date: Tue, 01 Sep 2009 01:18:10 -0700 (PDT)
Message-ID: <20090901.011810.103801726.davem@davemloft.net>
References: <20090901055039.824876937@vyatta.com>
	<20090901055128.466779045@vyatta.com>
	<4A9CCFC3.6020006@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53588
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751781AbZIAIRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 04:17:55 -0400
In-Reply-To: <4A9CCFC3.6020006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Sep 2009 09:39:47 +0200

> I was wondering if we could add a third parameter to 
> ndo_start_xmit() (and pass the struct netdev_queue *txq)
> in a smooth way, but could not find a solution.

Don't think that others didn't think about this too :-)

> Unconverted drivers would not care of this third param; but this
> should be provided by callers (like dev_hard_start_xmit())
>
> Most multiqueue drivers have to recompute it, and even monoqueue drivers
> have to call netif_stop_queue(dev)/netif_queue_stopped(dev), all
> using netdev_get_tx_queue(dev, 0) in the end...

At least that is a constant structure offset reference, and thus
computed at compile time.

Anyways, I like Stephen's netdev_tx_t changes and I'm build testing
them now in my net-next-2.6
