From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 16:56:02 -0700 (PDT)
Message-ID: <20070606.165602.118948582.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
	<20070606.154041.08321169.davem@davemloft.net>
	<1181172946.4064.87.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54142
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756138AbXFFXzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 19:55:46 -0400
In-Reply-To: <1181172946.4064.87.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 06 Jun 2007 19:35:46 -0400

> There is no potential for parallelizing on transmit that i can think of.
> Dave, please explain it slowly so i can understand it.
> 
> There is huge potential for parallelizing on receive. But i am certainly
> missing the value in the transmit.

I gave an example in another response, you have N processes
queueing up data for TCP or UDP or whatever in parallel on
different cpus, all going out the same 10gbit device.

All of them enter into ->hard_start_xmit(), and thus all of them try
to take the same netdev->tx_lock

If they have multiple TX queues, independantly programmable, that
single lock is stupid.

We could use per-queue TX locks for such hardware, but we can't
support that currently.
