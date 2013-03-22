From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Fri, 22 Mar 2013 10:11:39 -0400 (EDT)
Message-ID: <20130322.101139.1942128058226201237.davem@davemloft.net>
References: <E1UJ1fR-0004hs-4l@swissweb.swissdisk.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E1UJ1fR-0004hs-4l@swissweb.swissdisk.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Fleming <afleming@freescale.com>
Date: Wed, 13 Jul 2011 08:52:04 -0500

> The QDisc code does a bunch of locking which is unnecessary if
> you have hardware which handles all of the queueing. Add
> support for this, and skip over all of the queueing code if
> the feature is enabled on a given device, which breaks QDisc
> support on dpaa_eth, and also coopts the FCOE feature bit.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> Signed-off-by: Ben Collins <ben.c@servergy.com>

Sorry, no.

If we are going to support something like this then there needs to
be full coordination, configuration wise, so that if we enable
a qdisc that the hardware supports we submit it directly, but if
we enable a qdisc the HW does not support, we still use the software
qdisc.

This also means that we need to have a way to determine if the qdisc
configuration exceeds that parametorial limits of the device's HW
capabilities, and fallback to software qdisc in those cases too.
