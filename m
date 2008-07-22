From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] sfc: resolve tx multiqueue bug
Date: Tue, 22 Jul 2008 14:00:23 -0700 (PDT)
Message-ID: <20080722.140023.127726788.davem@davemloft.net>
References: <20080718180156.GH10471@solarflare.com>
	<20080718184925.GJ10471@solarflare.com>
	<20080722184118.GR10471@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60955
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754425AbYGVVAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:00:23 -0400
In-Reply-To: <20080722184118.GR10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 22 Jul 2008 19:41:19 +0100

> So long as a queue is only woken in response to TX completions, the current
> arrangement is fine.  However, sfc needs to tear down and restart hardware TX
> queues as part of some reconfiguration, self-test and recovery code, and I
> doubt it's the only such driver.

Mark the carrier off and packets will stop flowing to the driver.

Or, alternatively, take the necessary TX spinlocks around the
reconfiguration.

> I think the corresponding kernel queue must be stopped and then started when
> we do this (otherwise we could return NETDEV_TX_BUSY in hard_start_xmit, but
> I understand that to be deprecated).  So we must also wake the kernel queue
> if and only if it's considered active - but we don't know whether that's the
> case because deactivation is done asynchronously.

See above.
