From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Mon, 19 Sep 2011 16:56:12 -0400 (EDT)
Message-ID: <20110919.165612.160169795450854730.davem@davemloft.net>
References: <1316279044.14749.179.camel@deadeye>
	<4E776441.9090602@intel.com>
	<1316448352.2764.27.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590Ab1ISU4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 16:56:21 -0400
In-Reply-To: <1316448352.2764.27.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 19 Sep 2011 17:05:52 +0100

> But tx_max_coalesced_frames_irq is not supposed to be a work limit (and
> such a work limit doesn't seem useful in the absence of NAPI).  As I
> understand it, it is supposed to be an alternate moderation value for
> the hardware to use if a frame is sent while the IRQ handler is running.

Exactly, the ethtool settings modify what the hardware interrupt mechanisms
do, ragardless of whether those hardware interrupts trigger NAPI or not.

And this is precisely what we want, because optimal behavior of NAPI
absoulutely depends upon having the interrupt moderated in hardware
at least a little bit.
