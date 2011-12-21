From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] IPv6 : add multicast routing verify which
 net_device is lo
Date: Wed, 21 Dec 2011 14:11:38 -0500 (EST)
Message-ID: <20111221.141138.2054196549674078174.davem@davemloft.net>
References: <1324379424-18055-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20111221.011506.1770356582907889299.davem@davemloft.net>
	<4EF1A061.5030005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: wangxingtong@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215Ab1LUTLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 14:11:49 -0500
In-Reply-To: <4EF1A061.5030005@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Xingtong <wangxingtong@cn.fujitsu.com>
Date: Wed, 21 Dec 2011 17:01:21 +0800

> OK, David, I reproduce this as following :
> 
> 1) ip -6 route show | grep ff00
>    unreachable ff00::/8 dev lo  metric 1024  error -101
>    ff00::/8 dev eth1  metric 1024
> 
> 2) ip -6 route del ff00::/8 dev eth1
>    ip -6 route del ff00::/8 dev lo
> 
> 3) ip -6 route add ff00::/8 dev lo
>    ip -6 route add ff00::/8 dev eth1

My answer is "Don't ever do that."  The kernel sets up the
loopback device with all the necessary parameters you need
including the address, network prefix, and (once we revert
the recent bogus ipv6 autoconf patch) the multicast prefix.

There is no reason to ever explicit set the things that the
kernel takes care of for you.

That was exactly my point, the piece of userspace that has
started doing this needs to be fixed and we need to revert
Li Wei's recent patch.
