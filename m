From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: delete the statements limit icmp message in
 ip_error()
Date: Tue, 14 Jan 2014 17:04:58 -0800 (PST)
Message-ID: <20140114.170458.523577634295926662.davem@davemloft.net>
References: <52D265D4.9050600@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbaAOBE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:04:59 -0500
In-Reply-To: <52D265D4.9050600@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Sun, 12 Jan 2014 17:52:20 +0800

> Because after the icmp_send() is called, the icmpv4_xrlim_allow()
> will be called to limit the icmp message too.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

icmpv4_xrlim_allow() is different from what this code is doing.

There are seperate controls for ip_error() reporting, namely:

> -		if (peer->rate_tokens > ip_rt_error_burst)
 ...
> -		if (peer->rate_tokens >= ip_rt_error_cost)

And this is the only place where that is taken into account.

The icmpv4_xrlim_allow() is a top level limiting on all ICMPs,
this function is limiting specific kinds.

I am not applying this patch, sorry.
