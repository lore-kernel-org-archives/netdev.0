From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH][net-next] LRO: improve aggregation in case of zero TSecr packets
Date: Mon, 31 Aug 2009 20:15:18 +0300
Message-ID: <200908312015.18470.opurdila@ixiacom.com>
References: <200908270208.31581.opurdila@ixiacom.com> <20090830.221105.37473168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: themann@de.ibm.com, raisch@de.ibm.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:7358 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750929AbZHaRRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 13:17:37 -0400
In-Reply-To: <20090830.221105.37473168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 31 August 2009 08:11:05 David Miller wrote:

> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Thu, 27 Aug 2009 02:08:31 +0300
>
> > This fixes a temporary performance issue we noticed in back to back
> > TSO - LRO tests when such tests are run within five minutes after
> > boot.
> >
> > The TSval field of TCP packets is filled in based on the current
> > jiffie, which is initialized at -300*HZ. That means that in 5 minutes
> > after reboot it will wrap to zero.
>
> RFC1323 says we absolutely must ignore zero TSecr values.
>
> It is a bug that the stack emits a zero value when it means to give a
> real TSecr value that will be used.
>
> Probably we can do something like emit '1' when we would emit '0'
> based upon jiffies.
>
> And this would be an improvement from now in that having a off-by-one
> TSecr in this situation is better than emitting one which we can
> guarentee will be ignored.

Right, why did I thought that the LRO TSecr issue can happen even when 
emitting a right TSval ? :-/

I'll follow with a patch which takes this approach.

Thanks,
tavi
