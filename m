From: David Miller <davem@davemloft.net>
Subject: Re: [kernel,2.6.33-git11] lib8390: use spin_lock_irqsave for
 locking
Date: Mon, 08 Mar 2010 09:56:37 -0800 (PST)
Message-ID: <20100308.095637.175882761.davem@davemloft.net>
References: <20100307.152230.09914483.davem@davemloft.net>
	<20100308212433.0fa3e453.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ken_kawasaki@spring.nifty.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752412Ab0CHR4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 12:56:19 -0500
In-Reply-To: <20100308212433.0fa3e453.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Date: Mon, 8 Mar 2010 21:24:33 +0900

> 
>> This change is not correct.
>> 
>> disable_irq is being intentionally used because the reset
>> sequence can take a very long time and we don't want to
>> have cpu interrupts disabled during the entire sequence.
>> 
>> Otherwise slow serial devices will drop characters and
>> stuff like that.
> 
> 
> Actually, disable_irq is _not_ safe for lib8390 on SMP system.
> Same CPU or other CPU can call enable_irq.
> 
> so lib8390 does not work properly on my SMP system.

Then you need to fix that bug, because your patch here, again,
is not correct.
