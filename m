From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPV6] Fix ICMPv6 redirect handling with target multicast address
Date: Fri, 28 Sep 2007 17:50:38 -0700
Message-ID: <OF5FC97D70.5FD0A80A-ON88257365.00025E58-88257365.00048D1E@us.ibm.com>
References: <46FD2B37.6040502@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:49845 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310AbXI2Aul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 20:50:41 -0400
In-Reply-To: <46FD2B37.6040502@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian,
        A multicast address should never be the target of a neighbor
discovery request; the sender should use the mapping function for all
multicasts. So, I'm not sure that your example can ever happen, and it
certainly is ok to send ICMPv6 errors to multicast addresses in general.
But I don't see that it hurts anything. either (since it should never 
happen :-)),
so I don't particularly object, either.
        I think it'd also be better if you add the check to be:

        if (ipv6_addr_type(target) & 
(IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST))

or something along those lines, rather than reproducing ipv6_addr_type() 
code
separately in a new ipv6_addr_linklocal() function.

                                                +-DLS


