From: David Miller <davem@davemloft.net>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 18 Sep 2006 07:09:05 -0700 (PDT)
Message-ID: <20060918.070905.98863400.davem@davemloft.net>
References: <p73k6414lnp.fsf@verdi.suse.de>
	<20060918090330.GA9850@tentacle.sectorb.msk.ru>
	<p73eju94htu.fsf@verdi.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: master@sectorb.msk.ru, hawk@diku.dk, harry@atmos.washington.edu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49868
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965246AbWIROJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 10:09:12 -0400
To: ak@suse.de
In-Reply-To: <p73eju94htu.fsf@verdi.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: 18 Sep 2006 11:58:21 +0200

> For netdev: I'm more and more thinking we should just avoid the
> problem completely and switch to "true end2end" timestamps. This
> means don't time stamp when a packet is received, but only when it
> is delivered to a socket. The timestamp at receiving is a lie
> anyways because the network hardware can add an arbitary long delay
> before the driver interrupt handler runs. Then the problem above
> would completely disappear.

I don't think this is wise.

People who run tcpdump want "wire" timestamps as close as possible.
Yes, things get delayed with the IRQ path, DMA delays, IRQ
mitigation and whatnot, but it's an order of magnitude worse if
you delay to user read() since that introduces also the delay of
the packet copies to userspace which are significantly larger than
these hardware level delays.  If tcpdump gets swapped out, the
timestamp delay can be on the order of several seconds making it
totally useless.

Andi, you will need to find another solution to this problem :-)

