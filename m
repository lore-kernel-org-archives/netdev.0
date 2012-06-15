From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash via
 /proc/net/ipv6_route
Date: Fri, 15 Jun 2012 06:56:55 -0400
Message-ID: <20120615105655.GA22945@hmsreliant.think-freely.org>
References: <e4b53a15fadbe5c1aa5402fcc8172b0ee281da33.1339750783.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59538 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756514Ab2FOK5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 06:57:09 -0400
Content-Disposition: inline
In-Reply-To: <e4b53a15fadbe5c1aa5402fcc8172b0ee281da33.1339750783.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 15, 2012 at 11:00:17AM +0200, Thomas Graf wrote:
> /proc/net/ipv6_route reflects the contents of fib_table_hash. The proc
> handler is installed in ip6_route_net_init() whereas fib_table_hash is
> allocated in fib6_net_init() _after_ the proc handler has been installed.
> 
> This opens up a short time frame to access fib_table_hash with its pants
> down.
> 
> fib6_init() as a whole can't be moved to an earlier position as it also
> registers the rtnetlink message handlers which should be registered at
> the end. Therefore split it into fib6_init() which is run early and
> fib6_init_late() to register the rtnetlink message handlers.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
Reviewed-by: Neil Horman <nhorman@tuxdriver.com>

> 
