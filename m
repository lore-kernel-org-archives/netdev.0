From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: set accept_ra_rt_info_max_plen to 128 by default
Date: Thu, 20 Mar 2014 03:02:38 +0100
Message-ID: <20140320020238.GK12291@order.stressinduktion.org>
References: <20140319172210.GA29745@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47661 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbaCTCCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 22:02:39 -0400
Content-Disposition: inline
In-Reply-To: <20140319172210.GA29745@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2014 at 06:22:10PM +0100, Jiri Bohac wrote:
> I have been looking for the reason behind the default of
> accept_ra_rt_info_max_plen being 0. No luck.
> 
> The feature has been introduced by 09c884d4 ([IPV6]: ROUTE: Add
> accept_ra_rt_info_max_plen sysctl).
> 
> The only relevant discussion I found was
> http://markmail.org/message/5m34bfzhox6y5lcf
> with no explanation.
> 
> I imagine that the motivation for setting
> accept_ra_rt_info_max_plen to 0 would be security concerns.
> 
> However, RFC 4191, section "6. Security Consideration", concludes
> that the new features don't increase the risks already present:
> 
> 	A malicious node could send Router Advertisement messages, specifying
> 	a High Default Router Preference or carrying specific routes, with
> 	the effect of pulling traffic away from legitimate routers.  However,
> 	a malicious node could easily achieve this same effect in other ways.
> 
> 	For example, it could fabricate Router Advertisement messages with a
> 	zero Router Lifetime from the other routers, causing hosts to stop
> 	using the other routes.  By advertising a specific prefix, this
> 	attack could be carried out in a less noticeable way.  However, this
> 	attack has no significant incremental impact on Internet
> 	infrastructure security.
> 
> Sounds reasonable to me.
> 
> Also, RFC 6434 has been published since, and under 5.3. it says:
> 
> 	Small Office/Home Office (SOHO) deployments supported by routers
> 	adhering to [RFC6204] use RFC 4191 to advertise routes to certain
> 	local destinations.  Consequently, nodes that will be deployed in
> 	SOHO environments SHOULD implement RFC 4191.
> 

My concern with the kernel adding arbitrary length prefix routes to
the routing table is, that this could enable attacks on VPN software
by advertising smaller prefixes thus still leaving basic connectivity
intact but rerouting VPN internal traffic around the VPN tunnel because
of the more specific lookup.

Sure, this also is a problem for DHCP/IPv4 setups, but that is a concern
of userspace. ;)

I am totally fine with your reasoning and don't know what the initial
motivation for the default setting was, but I am a bit hesitant about
this change.

Greetings,

  Hannes
