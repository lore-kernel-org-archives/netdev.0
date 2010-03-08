From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: [kernel,2.6.33-git11] lib8390: use spin_lock_irqsave for
 locking
Date: Mon, 8 Mar 2010 21:24:33 +0900
Message-ID: <20100308212433.0fa3e453.ken_kawasaki@spring.nifty.jp>
References: <20100307.152230.09914483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg507.nifty.com ([202.248.238.87]:47312 "EHLO
	userg507.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755030Ab0CHMZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 07:25:11 -0500
In-Reply-To: <20100307.152230.09914483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This change is not correct.
> 
> disable_irq is being intentionally used because the reset
> sequence can take a very long time and we don't want to
> have cpu interrupts disabled during the entire sequence.
> 
> Otherwise slow serial devices will drop characters and
> stuff like that.


Actually, disable_irq is _not_ safe for lib8390 on SMP system.
Same CPU or other CPU can call enable_irq.

so lib8390 does not work properly on my SMP system.

Ken.

