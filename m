From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Wed, 20 Jul 2011 18:29:53 +0200
Message-ID: <20110720162953.GC11692@midget.suse.cz>
References: <20110719180222.GA7509@midget.suse.cz>
 <20110720091556.619a0c14@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36390 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483Ab1GTQ3z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 12:29:55 -0400
Content-Disposition: inline
In-Reply-To: <20110720091556.619a0c14@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2011 at 09:15:56AM -0700, Stephen Hemminger wrote:
> > When the cable is unplugged and plugged in again, we already get
> > notified through linkwatch -> netdev_state_change ->
> >   -> call_netdevice_notifiers(NETDEV_CHANGE, ...)
> > However, if the device has already been autoconfigured,
> > addrconf_notify() only handles this event by printing a
> > message.

...

> If the driver drops the link during suspend then the necessary link
> events happen to keep bridging, ipv6, bonding and all the other possible
> network protocols happy.

OK, so maybe providing the link event on suspend/resume should be
left to the drivers.

The main problem persists: IPv6 currently does nothing when the link goes
down and returns. Shouldn't the kernel anticipate that the new
network could be different, forget all the autoconfigured
parameters and restart the autoconfiguration?

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

