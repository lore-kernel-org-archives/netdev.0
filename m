From: Scott Wood <scottwood@freescale.com>
Subject: Re: [RFC fs_enet: Convert MII bitbang driver to use GPIO lib
Date: Mon, 21 Apr 2008 12:56:27 -0500
Message-ID: <20080421175627.GD4134@ld0162-tx32.am.freescale.net>
References: <200804161640.42693.laurentp@cse-semaphore.com> <20080416160540.GB442@polina.dev.rtsoft.ru> <200804161809.40805.laurentp@cse-semaphore.com> <200804181334.34229.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, avorontsov@ru.mvista.com,
	netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:33242 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751AbYDUR4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 13:56:32 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw02.freescale.net (8.12.11/de01egw02) with ESMTP id m3LHuSYo017868
	for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 10:56:28 -0700 (MST)
Received: from ld0162-tx32.am.freescale.net (ld0162-tx32.am.freescale.net [10.82.19.112])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m3LHuRZi004581
	for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 12:56:27 -0500 (CDT)
Content-Disposition: inline
In-Reply-To: <200804181334.34229.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 18, 2008 at 01:34:29PM +0200, Laurent Pinchart wrote:
> Scott Wood was concerned in 
> http://patchwork.ozlabs.org/linuxppc/patch?id=17490 that the gpio lib might 
> be an unnecessary burden for memory-constraint platforms. Should we keep two 
> mdio bitbang drivers, one with direct access to the ports and one using gpio 
> lib ? The later solves the concurrent access issues present in the current 
> fs_enet mdio bitbang driber.

The memory-constrained platform I had in mind was 8xx, which doesn't use
bitbanged MDIO.  It might nice to keep the gpiolib bit separate to avoid
situations such as ep8248e where mdiobb would be the only thing requiring
a gpiolib binding, though -- but it shouldn't be two separate bitbang
drivers, just the existing bitbang driver plus some glue code that binds
it to gpiolib.

-Scott
