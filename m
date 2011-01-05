From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v3 08/10] ARM: mxs: add ocotp read function
Date: Wed, 5 Jan 2011 18:35:09 +0000
Message-ID: <20110105183509.GH8638@n2100.arm.linux.org.uk>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com> <1294236457-17476-9-git-send-email-shawn.guo@freescale.com> <20110105161235.GA2112@gallagher> <20110105164409.GV25121@pengutronix.de> <20110105172501.GB2112@gallagher> <20110105175617.GD12222@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, gerg@snapgear.com,
	B32542@freescale.com, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, bryan.wu@canonical.com, baruch@tkos.co.il,
	w.sang@pengutronix.de, r64343@freescale.com,
	Shawn Guo <shawn.guo@freescale.com>, eric@eukrea.com,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lw@karo-electronics.de
To: Jamie Lokier <jamie@shareable.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:40715 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab1AESfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 13:35:33 -0500
Content-Disposition: inline
In-Reply-To: <20110105175617.GD12222@shareable.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 05, 2011 at 05:56:17PM +0000, Jamie Lokier wrote:
> cpu_relax() is a hint to the CPU to, for example, save power or be
> less aggressive on the memory bus (to save power or be fairer).
> 
> Currently these architectures do more than just a barrier in cpu_relax():
> x86, IA64, PowerPC, Tile and S390.
> 
> Although it's just a hint on ARM at the moment, it might change in
> future - especially with power mattering on so many ARM systems.
> (Even now, just changing it to a very short udelay might save power
> on existing ARMs without breaking drivers.)

I think that's a matter for what the loop is doing.  If it's polling
a memory location then it probably has no effect what so ever.  If
the loop is spinning on a device, then the CPU will have to wait for
the read to complete which will slow it down.

It's something that would need very careful evaluation, and is probably
something that's very platform and loop specific.

> By the way, I see ARM defines cpu_relax as smp_mb() on arch >= 6.  Is
> that correct and useful?  On other architectures*, barrier() is enough
> of a barrier, but it's conceivable that smp_mb() would have some
> ARM-specific fairness or bus activity benefit - in which case it
> should probably be mb().

See a discussion last year with Linus.  It's there to ensure that one CPU
spinning on a variable can see a write by another CPU to that same
variable.  Without the barrier, the visibility effects are unbounded on
ARMv6 - and it's only like that for ARMv6, not >= ARMv6.
