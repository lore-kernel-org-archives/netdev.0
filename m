From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Tue, 22 Oct 2013 12:53:58 -0700
Message-ID: <5266D7D6.9000309@intel.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	s.hauer@pengutronix.de, nbd@openwrt.org, blogic@openwrt.org,
	jogo@openwrt.org, gary@mlbassoc.com,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:18571 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754923Ab3JVTyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 15:54:00 -0400
In-Reply-To: <1382466229-15123-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2013 11:23 AM, Florian Fainelli wrote:
> This patch adds an Ethernet Switch generic netlink configuration API
> which allows for doing the required configuration of managed Ethernet
> switches commonly found in Wireless/Cable/DSL routers in the market.
>
> Since this API is based on the Generic Netlink infrastructure it is very
> easy to extend a particular switch driver to support additional features
> and to adapt it to specific switches.
>

> So far the API includes support for:
>
> - getting/setting a port VLAN id
> - getting/setting VLAN port membership
> - getting a port link status
> - getting a port statistics counters
> - resetting a switch device
> - applying a configuration to a switch device
>

Did you consider exposing each physical switch port as a netdevice on
the host? I would assume your switch driver could do this.

Then you can drop the port specific attributes (link status, stats, etc)
and use existing interfaces. The win being my tools work equally well on
your real switch as they do on my software switch. Also by exposing net
devices you provide a mechanism to send packets over the port and trap
control packets.

Next instead of creating a switch specific netlink API could you use
the existing FDB API? Again what I would like is for my existing
applications to run on the switch without having to rewrite them. For
example it would be great to have 'bridge fdb show dev myswitch' report
the correct tables for both the Sw bridge, a real switch bridge, and
for the embedded SR-IOV bridge case.

I added Jamal and Neil because I think I remember talking about similar
ideas with them before.

Thanks,
.John
