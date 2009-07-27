From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: Re: [PATCH NEXT 12/12] netxen: update version to 4.0.41
Date: Mon, 27 Jul 2009 14:51:28 -0700
Message-ID: <4A6E2160.1090704@qlogic.com>
References: <20090727.103842.52201957.davem@davemloft.net>	<20090727.105403.202219074.davem@davemloft.net>	<7608421F3572AB4292BB2532AE89D56581877E22A4@AVEXMB1.qlogic.org> <20090727.123807.268367807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50188 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612AbZG0Vv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 17:51:28 -0400
In-Reply-To: <20090727.123807.268367807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Agreed that it duplicates work in individual drivers,
and the naming style followed by different vendors.

But the problem is ethtool can work only after driver
has successfully initialized interfaces. Otherwise,
ethtool gets no chance to tune up/down.

The driver defaults are for tuned for typical use cases.
On some frugal systems with lower amount of RAM, the
driver bails out failing to allocate enough ring space
or rx buffers [especially for 32-bit kernels]. This is
also a problem for multi-function (more than one PCI
function per physical port) mode, where number of
interfaces and hence the memory consumption gets
multiplied. For these cases something that can set
the bar before device initialization, is quite helpful.

Thanks,
Dhananjay



David Miller wrote:
> No, it is not good.
> 
> With module parameters we:
> 
> 1) duplicate functionality
> 
> 2) every device driver will name the module parms differently,
>    therefore the interface for the user is different for every device
>    type
> 
> We discuss this all the time, and this is a pretty deep rooted
> belief and requirement for all network drivers.

