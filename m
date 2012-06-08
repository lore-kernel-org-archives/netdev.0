From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: fix a race in l2tp_ip_sendmsg()
Date: Fri, 08 Jun 2012 14:31:47 -0700 (PDT)
Message-ID: <20120608.143147.1838350639362568199.davem@davemloft.net>
References: <1339172700.6001.128.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, denys@visp.net.lb
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935Ab2FHVbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 17:31:49 -0400
In-Reply-To: <1339172700.6001.128.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jun 2012 18:25:00 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 081b1b1bb27f (l2tp: fix l2tp_ip_sendmsg() route handling) added
> a race, in case IP route cache is disabled.
> 
> In this case, we should not do the dst_release(&rt->dst), since it'll
> free the dst immediately, instead of waiting a RCU grace period.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Working with a zero-ref'd object is always playing with fire even
when we "know what we are doing" :-)

Applied and queued up for -stable, thanks Eric.
