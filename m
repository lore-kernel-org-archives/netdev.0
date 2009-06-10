From: David Miller <davem@davemloft.net>
Subject: Re: SUN Neptune byte order bug in TCAM filter/ethtool
Date: Wed, 10 Jun 2009 01:26:53 -0700 (PDT)
Message-ID: <20090610.012653.184952517.davem@davemloft.net>
References: <18945.47047.877878.307515@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, Matheos.Worku@Sun.COM,
	Jens.Laas@its.uu.se
To: robert@robur.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754430AbZFJQ6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 12:58:04 -0400
In-Reply-To: <18945.47047.877878.307515@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <robert@robur.slu.se>
Date: Wed, 6 May 2009 18:16:07 +0200

> # This rule makes the TCAM drop pkts with IP-src 10.10.10.1 
> # Note the reversed byte-order. Machine is Opteron little Endian.
> 
> ethtool -N  eth0  rx-class-rule-add ip4 udp sip 1.10.10.10 drop  
> 
> # The rule listed
> 
> ethtool  -n eth0  rx-class-rule-all 
> Total 1 rules
> 
>       IPv4 Rule:   ID[84] Target[Discard]
>       IP src addr[1.10.10.10] mask[255.255.255.255]
>       IP dst addr[0.0.0.0] mask[0.0.0.0]
>       L4 proto[UDP]
>       L4 src port[0] mask[0x0]
>       L4 dst port[0] mask[0x0]
>       IP TOS[0x0] mask[0x0]

I suspect that ethtool is probably to blame, the kernel seems
sane and treats the IP addresses, ports, etc. as big-endian.
