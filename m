From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash via
 /proc/net/ipv6_route
Date: Sun, 17 Jun 2012 02:11:27 -0400
Message-ID: <20120617061127.GC27921@canuck.infradead.org>
References: <e4b53a15fadbe5c1aa5402fcc8172b0ee281da33.1339750783.git.tgraf@suug.ch>
 <20120615105655.GA22945@hmsreliant.think-freely.org>
 <20120615.153240.1699971156820399680.davem@davemloft.net>
 <20120615.221502.1196734470412725503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:45643 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab2FQGLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 02:11:33 -0400
Content-Disposition: inline
In-Reply-To: <20120615.221502.1196734470412725503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 15, 2012 at 10:15:02PM -0700, David Miller wrote:
> Thomas, this patch is buggy.
> 
> We will now initialize fib6_init() before ip6_net_route_net_ops is registerd.
> 
> This causes fib6_net_init() to run before net->ipv6.ip6_null_entry it
> initialized.
> 
> Any route lookup will crash when we dereference a root's ->leaf
> because it will be NULL.
> 
> Please test your changes more thoroughly.

Sorry, that this has slipped through. I must have booted the wrong
kernel. I even had this run by an external tester to confirm that
the original panic disapppeared...

I'll come up with a new fix.
