From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Create and use fib_compute_spec_dst() helper.
Date: Thu, 05 Jul 2012 00:59:40 -0700 (PDT)
Message-ID: <20120705.005940.1078811938047681715.davem@davemloft.net>
References: <1341415267.2583.2120.camel@edumazet-glaptop>
	<20120704.161335.1503971699878518173.davem@davemloft.net>
	<1341474745.2583.3325.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174Ab2GEH7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 03:59:43 -0400
In-Reply-To: <1341474745.2583.3325.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jul 2012 09:52:25 +0200

> [PATCH] ipv4: defer fib_compute_spec_dst() call
> 
> ip_options_compile() can avoid calling fib_compute_spec_dst()
> by default, and perform the call if needed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Yes, this is a great idea.  Actually in some obscure cases your
change can cause us to compute it more than once I think.

I'd suggest we do something like create a helper function above this
code in ip_options.c that checks whether spec_dst is INADDR_ANY or
not, to guard computing it multiple times.

Could you put together a quick patch like that?
