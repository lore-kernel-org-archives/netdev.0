From: David Miller <davem@davemloft.net>
Subject: Re: Excess use of packed attribute
Date: Mon, 07 Aug 2006 16:20:26 -0700 (PDT)
Message-ID: <20060807.162026.106265856.davem@davemloft.net>
References: <20060807133423.11bfbff3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1424
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751179AbWHGXUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:20:24 -0400
To: shemminger@osdl.org
In-Reply-To: <20060807133423.11bfbff3@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 7 Aug 2006 13:34:23 -0700

> Silly offenders:	include/net/ipx.h
> 			include/net/ieee80211.h
> 			include/net/ip6_tunnel.h
> 			include/net/ndisc.h
> 			include/linux/if_ether.h
> 			include/linux/if_fddi.h
> 		
> 			include/linux/sctp.h -- really bad

The ndisc.h one, for example, is needed for cases like ARM.

The if_ether.h one is also needed, or else for:

	struct ethhdr *eth;

"eth + 1" would do the wrong thing as the compiler would
align the structure to the native pointer size or similar.
This is an issue because ethhdr is 14 bytes in size.
