From: David Miller <davem@davemloft.net>
Subject: Re: IrDA woes..
Date: Thu, 02 Jan 2014 19:05:11 -0500 (EST)
Message-ID: <20140102.190511.837169616985438729.davem@davemloft.net>
References: <CA+55aFyFAaHgoTe_ZVs3F0Giy4qDndKsE6GbB4DgcaK7QkXOkA@mail.gmail.com>
	<20140102.174136.1587468571877727139.davem@davemloft.net>
	<CA+55aFwBCATuEWKZTK7aueSyO4JAOBGvqq3FZnsqynmouGOQog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbaACAFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 19:05:12 -0500
In-Reply-To: <CA+55aFwBCATuEWKZTK7aueSyO4JAOBGvqq3FZnsqynmouGOQog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 2 Jan 2014 14:47:44 -0800

> You could use spin_lock_bh(), but if it's true that it's all in a
> softirq context, I think it should be safe to just do "spin_lock()".
> Afaik, there is nothing that actually does anything in real hardirq
> context in there. I *think* all the network _rcv() functions are
> called from softirqs, right?

I'm worried that mixing hardIRQ locking (via the direct calls to
skb_dequeue() et al.) with explicit softIRQ locking will make lockdep
complain.
