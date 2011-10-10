From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: RE: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Mon, 10 Oct 2011 10:29:40 +0200
Message-ID: <1318235380.29415.411.camel@pasglop>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AE77@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@dev.mellanox.co.il>, netdev@vger.kernel.org,
	Eli Cohen <eli@mellanox.co.il>, linuxppc-dev@lists.ozlabs.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45973 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353Ab1JJIaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 04:30:07 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AE77@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-10 at 09:20 +0100, David Laight wrote:
> 
> For the above I'd actually suggest making 'doorbell_qpn' have the
> correct endianness in order to avoid the (potential) swap every
> time it is set.

Well, the problem is that either you'll end up swapping on x86 or you'll
end up swapping on ppc, there is no "native" MMIO accessor that allow
you to do a no-swap access whatever the arch you are on. Or rather,
there is the __raw_ one but you shouldn't use it for most things :-)
(Because it also doesn't have the right memory barriers).

So I'd rather they do it right using the simpler method, the cost of
swap is going to be negligible, probably not even measurable, and if and
only if they think they can improve on that in a second step, then
consider doing otherwise with appropriate measurements showing a
significant difference.

> You also need to treble-check the required endianness for the
> 'vlan_tag' in the tx descriptor. What would be needed is the
> MAC PCI slave were on an x86 (LE) system.

Cheers,
Ben.
