From: David Miller <davem@davemloft.net>
Subject: Re: RFC: crash in fib6_clean_all() while loading ipv6 module
Date: Mon, 09 Sep 2013 13:27:20 -0400 (EDT)
Message-ID: <20130909.132720.1372904024173191622.davem@davemloft.net>
References: <20130909100515.GA16056@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283Ab3IIR1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 13:27:25 -0400
In-Reply-To: <20130909100515.GA16056@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon, 9 Sep 2013 12:05:15 +0200

> This could be prevented by setting a flag when ip6_route_init() is
> complete and not calling fib6_run_gc() from ndisc_netdev_event() until
> the flag is set. However, I don't like the idea of adding a test which
> will be useful only in a short window while loading ipv6 module.

Please just initialize the parts of ipv6 in the correct order necessary
to prevent this problem.

I stronly dislike using flags when it's simply an initialization
ordering problem.  It's just like registering a device interrupt
handle before the driver's data structures are properly setup.
