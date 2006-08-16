From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: powerpc/cell spidernet bottom half
Date: Wed, 16 Aug 2006 14:32:03 -0700 (PDT)
Message-ID: <20060816.143203.11626235.davem@davemloft.net>
References: <44E38157.4070805@garzik.org>
	<20060816.134640.115912460.davem@davemloft.net>
	<200608162324.47235.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linas@austin.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	jklewis@us.ibm.com, Jens.Osterkamp@de.ibm.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55444
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932238AbWHPVcr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 17:32:47 -0400
To: arnd@arndb.de
In-Reply-To: <200608162324.47235.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 16 Aug 2006 23:24:46 +0200

> We first had an interrupt per descriptor, then got rid of all TX
> interrupts and replaced them by timers to reduce the interrupt load,
> but reducing throughput in the case where user space sleeps on a full
> socket buffer.

The best schemes seem to be to interrupt mitigate using a combination
of time and number of TX entries pending to be purged.  This is what
most gigabit chips seem to offer.

On Tigon3, for example, we tell the chip to interrupt if either 53
frames or 150usecs have passed since the first TX packet has become
available for reclaim.

That bounds the latency as well as force the interrupt if a lot of TX
work becomes available.

Can spidernet be told these kinds of parameters?  "N packets or
X usecs"?

This is all controllable via ethtool btw (via ETHTOOL_{S,G}COALESCE),
so you can experiment if you want.
