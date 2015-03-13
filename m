From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix statistics locking scheme
Date: Fri, 13 Mar 2015 15:51:47 -0400 (EDT)
Message-ID: <20150313.155147.274140101234642831.davem@davemloft.net>
References: <1426253565-10302-1-git-send-email-Yuval.Mintz@qlogic.com>
	<20150313.123822.1761706097366192562.davem@davemloft.net>
	<B5657A6538887040AD3A81F1008BEC63C10D9E@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717AbbCMTvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:51:49 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63C10D9E@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Fri, 13 Mar 2015 19:02:36 +0000

>> This is terrible.
> 
>> Either you use locking to protect critical sections, or you don't.
> 
>> I do not want to see any code that enters the critical
>> section when the locked state cannot be acquired.
> 
> I've no real objection to re-spinning this, 
> given that it's an error flow we've never actually encountered.
> 
> Do notice that this doesn't change existing behavior of code.

I disagree.

The existing code took the spinlock unconditionally, and only
executed the critical section under the lock.

This exact place is where you are adding the semaphore timeout
stuff I am specifically objecting too.
