From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [BUG] VPN broken in net-next
Date: Fri, 4 Mar 2011 10:39:55 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103041013360.1452@ja.ssi.bg>
References: <20110302.165421.258093056.davem@davemloft.net> <alpine.LFD.2.00.1103031414240.1677@ja.ssi.bg> <alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg> <20110303.112328.59677094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49532 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751338Ab1CDIfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2011 03:35:37 -0500
In-Reply-To: <20110303.112328.59677094.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Thu, 3 Mar 2011, David Miller wrote:

> I suspect that even if we need to handle prefixes, we can still use
> the hash for optimistic lookup, and fallback to a local table FIB
> inspection if that fails.

 	Yes, as ip_route_output_slow uses __ip_dev_find for
fl4_src there should be some kind of fallback to local table,
so that traffic from 127.0.0.2 to 127.0.0.3 or other local
subnets on loopback can work. Another option is to use
inet_addr_onlink but I suspect people can add many addresses
on loopback: inet_addr_onlink(loopback_indev, addr, 0)

Regards

--
Julian Anastasov <ja@ssi.bg>
