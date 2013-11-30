From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] Fix ARM BUILD_BUG_ON() errors with batman-adv
Date: Sat, 30 Nov 2013 23:03:20 +0000
Message-ID: <20131130230319.GB16735@n2100.arm.linux.org.uk>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk> <20131130.160547.837987320410619405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mareklindner@neomailbox.ch, sw@simonwunderlich.de,
	antonio@meshcoding.com, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:43759 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab3K3XDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 18:03:51 -0500
Content-Disposition: inline
In-Reply-To: <20131130.160547.837987320410619405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 30, 2013 at 04:05:47PM -0500, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Sat, 30 Nov 2013 19:15:53 +0000
> 
> > so there should be no undesired side effect from this packing.
> 
> There is a huge side effect from ever using the packed attribute, in
> that the compiler can assume absolutely nothing about the alignment of
> any object or sub-object of the type you apply this attribute to.
> 
> Even if it is "obvious" that some members will be aligned, the
> compiler cannot take advantage of this assumption because this
> attribute also means that an array of such elements might have
> arbitrary alignment.  So you when you get a pointer to one of these
> objects, the compiler has to assume the worst possible case.
> 
> This means using 4 byte loads to load a 32-bit quantity, always,
> unconditionally, no matter what.
> 
> That's why we should do whatever is necessary to align things properly
> by hand, and use packed only as the last possible and least desirable
> resort.
> 
> I'm not applying this, please try work to implement this more
> acceptably first.

Okay, someone else fixes this problem then, I've no idea how this can
be fixed.
