From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix ARM BUILD_BUG_ON() errors with batman-adv
Date: Sat, 30 Nov 2013 16:05:47 -0500 (EST)
Message-ID: <20131130.160547.837987320410619405.davem@davemloft.net>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mareklindner@neomailbox.ch, sw@simonwunderlich.de,
	antonio@meshcoding.com, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab3K3VFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 16:05:51 -0500
In-Reply-To: <20131130191553.GA16735@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sat, 30 Nov 2013 19:15:53 +0000

> so there should be no undesired side effect from this packing.

There is a huge side effect from ever using the packed attribute, in
that the compiler can assume absolutely nothing about the alignment of
any object or sub-object of the type you apply this attribute to.

Even if it is "obvious" that some members will be aligned, the
compiler cannot take advantage of this assumption because this
attribute also means that an array of such elements might have
arbitrary alignment.  So you when you get a pointer to one of these
objects, the compiler has to assume the worst possible case.

This means using 4 byte loads to load a 32-bit quantity, always,
unconditionally, no matter what.

That's why we should do whatever is necessary to align things properly
by hand, and use packed only as the last possible and least desirable
resort.

I'm not applying this, please try work to implement this more
acceptably first.

Thanks.
