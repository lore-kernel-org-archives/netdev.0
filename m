From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] niu: fix SMP race protecting rx_rings and tx_rings
Date: Thu, 03 Feb 2011 15:53:13 -0800 (PST)
Message-ID: <20110203.155313.115940720.davem@davemloft.net>
References: <20110203231805.GA3710@redhat.com>
	<20110203.152214.59684545.davem@davemloft.net>
	<20110203234748.GB3710@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49972
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754687Ab1BCXwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 18:52:39 -0500
In-Reply-To: <20110203234748.GB3710@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fleitner@redhat.com>
Date: Thu, 3 Feb 2011 21:47:48 -0200

> On Thu, Feb 03, 2011 at 03:22:14PM -0800, David Miller wrote:
>> One thing I'm worried about with your patch is that the statistics
>> method can be called in basically any context, therefore a sleeping
>> lock like the rw_semaphore is probably not usable.
>> 
>> In fact I'm going to revert your patch for now because of this issue.
> 
> Oops, I didn't see it there.  I thought all calls there were process
> context.  Anyway, RCU then...

Yes, one example is the dev_get_stats() call made in
drivers/net/bonding/bond_main.c, which occurs with a
rw spinlock held and BH disabled.

> thanks for reviewing it,

No problem.  I think I even have a way to fix this without using RCU
(directly).  Just some memory barriers during allocation of the
channels.

I'll post the patch after I'm done with it, thanks again Falvio.
