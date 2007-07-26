From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] [PATCH] IPv6: ipv6_addr_type() doesn't know
 about RFC4193 addresses
Date: Thu, 26 Jul 2007 13:59:04 -0400
Message-ID: <46A8E0E8.6080209@hp.com>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>	<20070725.171203.102545287.davem@davemloft.net> <18087.62656.490978.692574@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	sakkiped@starentnetworks.com
To: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:51953 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763424AbXGZR7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 13:59:51 -0400
In-Reply-To: <18087.62656.490978.692574@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Johnson wrote:
> David Miller writes:
>> Contrarily, there may be ipv6_addr_type() call sites that really
>> do want to reject rfc4193 addresses.
> 
> A quick look through the callers and only these functions should be
> effected, they check either RESERVED or UNICAST from ipv6_addr_type():
> 
> net/ipv6/addrconf.c:                ipv6_dev_get_saddr()
> net/ipv6/exthdrs.c:                 ipv6_dest_hao()   
> net/ipv6/ip6_tunnel.c:              ip6_tnl_set_cap()
> net/ipv6/netfilter/ip6t_REJECT.c:   send_reset()
> net/ipv6/route.c:                   ip6_route_add()
> net/ipv6/route.c:                   ip6_pkt_drop()
> net/sctp/ipv6.c:                    sctp_v6_available()
> net/sctp/ipv6.c:                    sctp_v6_addr_valid()
> 

Well, it's not just for SCTP.  ULA address are considered of Global scope.
See this message
	http://marc.info/?l=linux-netdev&m=118492205915816&w=2

-vlad
