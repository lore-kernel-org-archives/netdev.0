From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Subject: Re: [PATCH] IPv6: ipv6_addr_type() doesn't know about RFC4193 addresses
Date: Wed, 25 Jul 2007 21:11:28 -0400
Message-ID: <18087.62656.490978.692574@zeus.sw.starentnetworks.com>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
	<20070725.171203.102545287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	sakkiped@starentnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.38.223.190] ([12.38.223.190]:1158 "EHLO
	mail.sw.starentnetworks.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752281AbXGZBLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 21:11:50 -0400
In-Reply-To: <20070725.171203.102545287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller writes:
> Contrarily, there may be ipv6_addr_type() call sites that really
> do want to reject rfc4193 addresses.

A quick look through the callers and only these functions should be
effected, they check either RESERVED or UNICAST from ipv6_addr_type():

net/ipv6/addrconf.c:                ipv6_dev_get_saddr()
net/ipv6/exthdrs.c:                 ipv6_dest_hao()   
net/ipv6/ip6_tunnel.c:              ip6_tnl_set_cap()
net/ipv6/netfilter/ip6t_REJECT.c:   send_reset()
net/ipv6/route.c:                   ip6_route_add()
net/ipv6/route.c:                   ip6_pkt_drop()
net/sctp/ipv6.c:                    sctp_v6_available()
net/sctp/ipv6.c:                    sctp_v6_addr_valid()

-- 
Dave Johnson
Starent Networks

