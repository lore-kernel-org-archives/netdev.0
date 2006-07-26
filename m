From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] [IPV6]: Policy Routing Rules
Date: Wed, 26 Jul 2006 16:40:28 -0700 (PDT)
Message-ID: <20060726.164028.13029784.davem@davemloft.net>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221850.124450582@postel.suug.ch>
	<20060726.163343.29813028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1727
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750731AbWGZXkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 19:40:13 -0400
To: tgraf@suug.ch
In-Reply-To: <20060726.163343.29813028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 26 Jul 2006 16:33:43 -0700 (PDT)

> Therfore, the better fix seems to be, to change the Makefile
> rule to be:
> 
> ipv6-$(CONFIG_IPV6_MULTIPLE_TABLES) += fib6_rules.o
> 
> Ok?

And once this is fixed, new problems crop up :-)

WARNING: net/ipv6/ipv6.o - Section mismatch: reference to .exit.text:fib6_rules_cleanup from .text between 'ip6_route_cleanup' (at offset 0xbfd4) and 'rt6_mtu_change_route'
WARNING: "fib_rules_dump" [net/ipv6/ipv6.ko] undefined!
WARNING: "fib_rules_register" [net/ipv6/ipv6.ko] undefined!
WARNING: "fib_rules_lookup" [net/ipv6/ipv6.ko] undefined!
WARNING: "fib_rules_unregister" [net/ipv6/ipv6.ko] undefined!

The fib_rules_* cases are easy to fix, simply export
those symbols using EXPORT_SYMBOL_GPL() in net/core/fib_rules.c

The other problem is a bit more onerous.  ip6_route_cleanup is not
marked __exit, since it is called from initialization as well as
exit contexts.  Therefore fib6_rules_cleanup() has to have it's
__exit marker deleted too.

IPv6 seems to build modular now with all of these issues taken
care of.  Thomas, please integrate these fixes into your patch.

Thanks.

