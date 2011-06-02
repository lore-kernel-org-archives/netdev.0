From: David Miller <davem@davemloft.net>
Subject: Re: TX watchdog vs link-layer flow control
Date: Thu, 02 Jun 2011 13:55:07 -0700 (PDT)
Message-ID: <20110602.135507.41941087812604236.davem@davemloft.net>
References: <1307047720.2812.59.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab1FBUzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:55:09 -0400
In-Reply-To: <1307047720.2812.59.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 02 Jun 2011 21:48:40 +0100

> However, even if the link is up it can still be blocked by link-layer
> flow control.  A customer report (which has not yet been reproduced
> here) suggests that when Ethernet flow control is enabled a switch may
> in some circumstances throttle the TX packet rate to the extent that a
> TX queue cannot be unblocked before the watchdog fires.  It is certainly
> possible for a misbehaving link partner to do this, and this should
> probably not be considered as a bug in the local hardware or driver!
> 
> TX may also be blocked by a 'remote fault' indication.  This should
> possibly be translated into netif_carrier_off(), but I'm not sure that
> all drivers will be able to detect remote fault without polling.
> 
> Perhaps dev_watchdog() should support a driver operation to poll for
> cases like this before it decides that the local device is actually
> misbehaving?
> 
> Even then, I can't think of a reliable way to detect a pause frame
> flood.  Also, drivers might well require process context for such an
> operation.

Frankly, if the switch can't take packets for several seconds I want a
notification as that's a serious condition.

In lieu of a reliable way to poll for these kinds of cases in order to
distinguish properly, I think what happens now is the best we can do.
