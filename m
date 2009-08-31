From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] LRO: improve aggregation in case of zero
 TSecr packets
Date: Sun, 30 Aug 2009 22:11:05 -0700 (PDT)
Message-ID: <20090830.221105.37473168.davem@davemloft.net>
References: <200908270208.31581.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: themann@de.ibm.com, raisch@de.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46882
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750951AbZHaFKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 01:10:51 -0400
In-Reply-To: <200908270208.31581.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Thu, 27 Aug 2009 02:08:31 +0300

> This fixes a temporary performance issue we noticed in back to back
> TSO - LRO tests when such tests are run within five minutes after
> boot.
> 
> The TSval field of TCP packets is filled in based on the current
> jiffie, which is initialized at -300*HZ. That means that in 5 minutes
> after reboot it will wrap to zero.

RFC1323 says we absolutely must ignore zero TSecr values.

It is a bug that the stack emits a zero value when it means to give a
real TSecr value that will be used.

Probably we can do something like emit '1' when we would emit '0'
based upon jiffies.

And this would be an improvement from now in that having a off-by-one
TSecr in this situation is better than emitting one which we can
guarentee will be ignored.
