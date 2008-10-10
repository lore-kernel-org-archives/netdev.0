From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2] bonding: send IPv6 neighbor advertisement on failover
Date: Fri, 10 Oct 2008 12:04:15 -0400
Message-ID: <48EF7CFF.4050405@hp.com>
References: <OFB8A232B8.61496942-ON882574DE.0051B425-882574DE.0052AFD3@us.ibm.com> <29444.1223654036@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:48472 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760942AbYJJQES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 12:04:18 -0400
In-Reply-To: <29444.1223654036@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	As a semi-related question, what does IPv6 do if it receives a
> gratutitous NA, and finds a duplicate?

If a node has an IPv6 neighbor entry and receives an unsolicited NA it 
will change it's state to stale, forcing a re-lookup on the next 
transmit.  An un-solicited NA will change the state to reachable.

> 	I agree that doing DAD would update the switches, peers, etc,
> but, if I'm reading the IPv6 code correctly, the delay between probes is
> one second (nd_tbl.retrans_time), and it looks like there's an initial
> delay of up to 1 second as well (in addrconf_dad_kick, the
> rtr_solicit_delay).  For failover purposes, we want to issue the
> gratuitous ARP or NA packets immediately with a minimal delay between
> probes.

Right, and since a bond failover event should be rare, I think sending 
the NA immediately is OK.  All those random delays are meant to cover 
the case, for example, when a router sends an advertisement with a new 
prefix - you don't want everyone that receives it to do DAD immediately 
since it could overwhelm the network.

-Brian
