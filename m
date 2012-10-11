From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 13:35:42 +0000
Message-ID: <201210111335.43177.arnd@arndb.de>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk> <1349959248.21172.8970.camel@edumazet-glaptop> <5076C78E.1020408@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	Jon Masters <jonathan@jonmasters.org>, netdev@vger.kernel.org,
	=?utf-8?q?M=C3=A5ns_Rullg=C3=A5rd?= <mans@mansr.com>,
	David Laight <David.Laight@aculab.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:59507 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab2JKNfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 09:35:55 -0400
In-Reply-To: <5076C78E.1020408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 October 2012, Rob Herring wrote:
> 
> On 10/11/2012 07:40 AM, Eric Dumazet wrote:
> > On Thu, 2012-10-11 at 12:28 +0000, Arnd Bergmann wrote:
> > 
> >>
> >> Rob Herring as the original reporter has dropped off the Cc list, adding
> >> him back.
> >>
> >> I assume that the calxeda xgmac driver is the culprit then. It uses
> >> netdev_alloc_skb() rather than netdev_alloc_skb_ip_align() in
> >> xgmac_rx_refill but it is not clear whether it does so intentionally
> >> or by accident.
> 
> This in fact does work and eliminates the unaligned traps. However, not
> all h/w can do IP aligned DMA (i.MX FEC for example), so I still think
> this is a questionable optimization by the compiler. We're saving 1 load
> instruction here for data that is likely already in the cache. It may be
> legal per the ABI, but the downside of this optimization is much greater
> than the upside.
> 

What about the other approach that Eric suggested for such hardware
in http://www.spinics.net/lists/arm-kernel/msg200206.html ?

	Arnd
