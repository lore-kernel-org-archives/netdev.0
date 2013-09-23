From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 11/11] sfc: Add static tracepoints to datapath
Date: Mon, 23 Sep 2013 16:51:07 +0100
Message-ID: <1379951467.2485.33.camel@bwh-desktop.uk.level5networks.com>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
	 <1379788592.1681.45.camel@bwh-desktop.uk.level5networks.com>
	 <20130923.020838.2084214261543483443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16121 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab3IWPvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 11:51:14 -0400
In-Reply-To: <20130923.020838.2084214261543483443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 02:08 -0400, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Sat, 21 Sep 2013 19:36:32 +0100
> 
> > These tracepoints support the driver-specific datapath feature tests
> > we're running internally, though they might be useful for other
> > purposes.  The skb fields are chosen to cover driver features
> > implemented now or likely to be added soon.
> > 
> > (Includes a bug fix from Edward Cree.)
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Make this generic, rather than specific to this driver.
> 
> You're putting a tracepoint right before calls to the generic core
> receive interfaces.  That makes no sense at all.

I can make these generic, but there are several reasons why I didn't try
to do so:

1. There already *are* static tracepoints there (net_dev_xmit,
netif_receive_skb, netif_rx).  Just not logging enough information for
driver testing - and not in quite the right places to do that
(net_dev_xmit is after ndo_start_xmit so skb may be freed;
netif_receive_skb doesn't know whether GRO was used).  So I assumed that
detailed trace events were not wanted.

2. Generic trace events would be subject to changes that could make them
unsuitable for Solarflare's tests.

3. In Solarflare's test framework the system under tests logs over the
network to the test controller, so that in case of a crash everything
leading up to it will be logged.  If all interfaces on the SUT are
traced then logging trace events over the 'house network' leads to an
infinite loop.  (But obviously this can be avoided with some filtering
on the SUT.)

4. Static tracepoints always have run-time overhead, so these should
probably be controlled by a kconfig option (as in this patch).  Changing
a kconfig option for the core is more disruptive than changing a kconfig
option for a module (reinstall+reboot vs rmmod+insmod).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
