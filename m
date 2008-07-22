From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] sfc: resolve tx multiqueue bug
Date: Tue, 22 Jul 2008 14:33:13 -0700 (PDT)
Message-ID: <20080722.143313.147630363.davem@davemloft.net>
References: <20080722184118.GR10471@solarflare.com>
	<20080722.140023.127726788.davem@davemloft.net>
	<48865157.20709@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56345
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753384AbYGVVdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 17:33:13 -0400
In-Reply-To: <48865157.20709@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 22 Jul 2008 17:29:59 -0400

> David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Tue, 22 Jul 2008 19:41:19 +0100
> > 
> >> So long as a queue is only woken in response to TX completions, the current
> >> arrangement is fine.  However, sfc needs to tear down and restart hardware TX
> >> queues as part of some reconfiguration, self-test and recovery code, and I
> >> doubt it's the only such driver.
> > 
> > Mark the carrier off and packets will stop flowing to the driver.
> 
> Yep.
> 
> Though based on looking at a lot of existing driver code, I think this 
> is sometimes unclear to driver writers -- when to manage carrier 
> (netif_carrier_on/off) and when to manage queue flow 
> (netif_queue_start/stop/wake).

This is true.

My current plan is to fix up as many drivers as possible, and
assuming the reality that we can't expect to fix them all
by 2.6.27 we will remove the WARN_ON_ONCE from __netif_schedule()
right before 2.6.27-final then reinstate it for the 2.6.28
merge window.
