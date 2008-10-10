From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2] bonding: send IPv6 neighbor advertisement on failover
Date: Fri, 10 Oct 2008 10:34:58 -0400
Message-ID: <48EF6812.2090600@hp.com>
References: <OFDFB5153E.E37AC842-ON882574DE.000CEB50-882574DE.000D286A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:30362 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756368AbYJJOfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 10:35:04 -0400
In-Reply-To: <OFDFB5153E.E37AC842-ON882574DE.000CEB50-882574DE.000D286A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
>> I don't see any way to address David Steven's comment since there is 
>> currently no NA tunable in the IPv6 code.
> 
> Brian,
>         How do you feel about doubling up with dad_transmits for that
> part?

I don't really want to since this is bonding-specific behavior, and 
we're not performing DAD for the address.  This is just another sysfs 
entry: /sys/class/net/bond*/bonding/num_unsol_na, not a sysctl.

>         At least the switch/cache updating portion is the same
> in both cases.

I don't think they are.  In the DAD case we're probing for another node 
that might have the address configured, in the bond failover case we 
want to update the switch quickly so we don't drop packets.

-Brian
