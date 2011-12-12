From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix for adding multicast route for loopback
 device automatically.
Date: Mon, 12 Dec 2011 18:49:29 -0500 (EST)
Message-ID: <20111212.184929.1998244574424635802.davem@davemloft.net>
References: <4EDF1481.1080106@cn.fujitsu.com>
	<20111207.150615.181825066035193136.davem@davemloft.net>
	<4EE00BAD.3010409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41337 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753840Ab1LLXuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 18:50:40 -0500
In-Reply-To: <4EE00BAD.3010409@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Thu, 08 Dec 2011 08:58:21 +0800

> The problem is that the resulting routing table depends on the sequence
> of interface's initialization and in some situation, that would block all
> muticast packets. Suppose there are two interfaces on my computer
> (lo and eth0), if we initailize 'lo' before 'eth0', the resuting routing
> table(for multicast) would be
> 
> # ip -6 route show | grep ff00::
> unreachable ff00::/8 dev lo metric 256 error -101
> ff00::/8 dev eth0 metric 256
> 
> When sending multicasting packets, routing subsystem will return the first
> route entry which with a error set to -101(ENETUNREACH).
> 
> I know the kernel will set the default ipv6 address for 'lo' when it is up
> and won't set the default multicast route for it, but there is no reason to
> stop 'init' program from setting address for 'lo', and that is exactly what
> systemd did.

Ok, I added this more detailed explanation to the commit message and
applied your patch.

Probably it is a good idea to explain things completely, with all details
and examples, in the commit message from the beginning :-)
