From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.38-rc8 build failure] net: bridge builtin vs. ipv6
 modular
Date: Thu, 10 Mar 2011 13:49:08 -0800 (PST)
Message-ID: <20110310.134908.226783215.davem@davemloft.net>
References: <1299752394.4109.31.camel@lat1>
	<20110310132801.4a919df2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@bof.de, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36114
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751020Ab1CJVsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 16:48:31 -0500
In-Reply-To: <20110310132801.4a919df2.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 10 Mar 2011 13:28:01 -0800

> This can be fixed in either of 2 ways.  One way is to require that the
> bridge code building depend on how the IPV6 code is built (builtin or modular);
> the other way is to handle the kconfig variations in net/bridge/br_multicast.c --
> but this loses some functionality if IPV6=m and BRIDGE=y.
> 
> I prefer the Kconfig patch over the br_multicast.c patch.
> Both patches are below for consideration.

I definitely prefer the Kconfig variant, although it's unfortunate that we
have a stateful dependency in the bridging multicast code.

IPV4 seems to let us use INADDR_ANY as the source address in the multicast
query, but IPV6 does not allow this (as per RFC 2710).

Anyways, I've applied the Kconfig patch, thanks Randy!
