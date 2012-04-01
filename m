From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1] ipv6: Fix RTM_GETROUTE's interpretation of RTA_IIF
 to be consistent with ipv4
Date: Sun, 01 Apr 2012 17:30:32 -0400 (EDT)
Message-ID: <20120401.173032.1881937766187683052.davem@davemloft.net>
References: <20120401170345.5ed75cab@pixies.home.jungo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: shmulik.ladkani@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120401170345.5ed75cab@pixies.home.jungo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Sun, 1 Apr 2012 17:03:45 +0300

> In IPv4, if an RTA_IIF attribute is specified within an RTM_GETROUTE
> message, then a route is searched as if a packet was received on the
> specified 'iif' interface.
> 
> However in IPv6, RTA_IIF is not interpreted in the same way:
> 'inet6_rtm_getroute()' always calls 'ip6_route_output()', regardless the
> RTA_IIF attribute.
> 
> As a result, in IPv6 there's no way to use RTM_GETROUTE in order to look
> for a route as if a packet was received on a specific interface.
> 
> Fix 'inet6_rtm_getroute()' so that RTA_IIF is interpreted as "lookup a
> route as if a packet was received on the specified interface", similar
> to IPv4's 'inet_rtm_getroute()' interpretation.
> 
> Reported-by: Ami Koren <amikoren@yahoo.com>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied, thanks.

> 1) An alternative: construction of an skb within 'inet6_rtm_getroute()'
>    and then calling 'ip6_route_input()' with the skb as an argument.
>    Thus, no need to split common code of 'ip6_route_input()'.
>    Less elegant IMO.

Agreed.

> 2) Better name for the new common function 'ip6_route_input_lookup()'
>    Will happily accept any better suggestions.

No, it's fine.

> 3) In IPv4 the 'ip_route_input()' call within 'inet_rtm_getroute()'is
>    protected by a 'local_bh_disable()' since dawn of history.
>    Not sure if similar protection needed within 'inet6_rtm_getroute()'.

Since all the code paths are shared more than on the ipv4 side, both
output and input route lookups can be done with and without BH
disabling.
