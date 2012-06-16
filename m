From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash
 via /proc/net/ipv6_route
Date: Sat, 16 Jun 2012 01:13:30 -0700 (PDT)
Message-ID: <20120616.011330.636639748049380489.davem@davemloft.net>
References: <20120615105655.GA22945@hmsreliant.think-freely.org>
	<20120615.153240.1699971156820399680.davem@davemloft.net>
	<20120615.221502.1196734470412725503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752628Ab2FPINc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2012 04:13:32 -0400
In-Reply-To: <20120615.221502.1196734470412725503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 15 Jun 2012 22:15:02 -0700 (PDT)

> We will now initialize fib6_init() before ip6_net_route_net_ops is registerd.
> 
> This causes fib6_net_init() to run before net->ipv6.ip6_null_entry it
> initialized.
> 
> Any route lookup will crash when we dereference a root's ->leaf
> because it will be NULL.

I've decided to revert this change for now.
