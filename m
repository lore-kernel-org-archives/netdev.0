From: David Miller <davem@davemloft.net>
Subject: Re: neigh_periodic_timer expires too often
Date: Sun, 02 Aug 2009 18:35:53 -0700 (PDT)
Message-ID: <20090802.183553.257296569.davem@davemloft.net>
References: <4A717985.7060909@nokia.com>
	<4A719CDB.3060004@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luciano.coelho@nokia.com, netdev@vger.kernel.org,
	tero.kristo@nokia.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754059AbZHCBfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 21:35:45 -0400
In-Reply-To: <4A719CDB.3060004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 30 Jul 2009 15:15:07 +0200

> [PATCH net-next-2.6] neigh: Convert garbage collection from softirq to workqueue
> 
> Current neigh_periodic_timer() function is fired by timer IRQ, and
> scans one hash bucket each round (very litle work in fact)
> 
> As we are supposed to scan whole hash table in 15 seconds, this means
> neigh_periodic_timer() can be fired very often. (depending on the number
> of concurrent hash entries we stored in this table)
> 
> Converting this to a workqueue permits scanning whole table, minimizing
> icache pollution, and firing this work every 15 seconds, independantly
> of hash table size.
> 
> This 15 seconds delay is not a hard number, as work is a deferrable one.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next-2.6, thanks!
