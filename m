From: David Miller <davem@davemloft.net>
Subject: Re: async network I/O, event channels, etc
Date: Thu, 27 Jul 2006 02:31:56 -0700 (PDT)
Message-ID: <20060727.023156.61758783.davem@davemloft.net>
References: <20060727074902.GC5490@2ka.mipt.ru>
	<20060727.010255.87351515.davem@davemloft.net>
	<20060727085812.GA24529@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1666
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751032AbWG0Jbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 05:31:36 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060727085812.GA24529@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 27 Jul 2006 12:58:13 +0400

> Btw, according to DMA allocations - there are some problems here too.
> Some pieces of the world can not dma behind 16mb, and someone can do it
> over 4gb.

I think people take this "DMA" in Ulrich's interface names too
literally.  It is logically something different, although it could be
used directly for this purpose.

View it rather as memory you have by some key based ID, but need to
explicitly map to access directly.

> Those physical pages can be managed within kernel and userspace can map
> them. But there is another possibility - replace slab allocation for
> network devices with allocation from premapped pool.
> That naturally allows to manage that pool for AIO needs and have
> zero-copy sending and receiving support. That is what I talked in
> netchannel topic when question about allocation/freeing cost in atomic
> context arised. I work on that solution, which can be used both for
> netchannels (and full userspace processing) and usual networking code.

Interesting idea, and yes I have been watching you stress test your
AVL tree code :))
