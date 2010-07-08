From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 16:49:58 +0100
Message-ID: <1278604198.16013.35.camel@achroite.uk.solarflarecom.com>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	 <1278571587.2543.9.camel@edumazet-laptop>
	 <1278581971.2651.10.camel@edumazet-laptop>
	 <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50903 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687Ab0GHPuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 11:50:01 -0400
In-Reply-To: <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-08 at 16:43 +0100, Ben Hutchings wrote:
> On Thu, 2010-07-08 at 11:39 +0200, Eric Dumazet wrote:
> > When we need to shape traffic with low speeds, we need to disable tso on
> > network interface :
> > 
> > ethtool -K eth0.2240 tso off
> > 
> > It seems vlan interfaces miss the set_tso() ethtool method.
> > Propagating tso changes from lower device is not always wanted, some
> > vlans want TSO on, others want TSO off.
[...]
> I think the vlan driver should also have a netdev notifier to handle
> feature changes on the underlying device.

To clarify, I think offload features should be disabled on a vlan device
if they are later disabled on the underlying device.  Propagating
changes to enable features, as you say, might not be wanted.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

