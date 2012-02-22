From: David Miller <davem@davemloft.net>
Subject: Re: route add default fails with ESRCH?
Date: Wed, 22 Feb 2012 18:56:25 -0500 (EST)
Message-ID: <20120222.185625.1452176745900047968.davem@davemloft.net>
References: <alpine.LFD.2.00.1202222319150.1603@ja.ssi.bg>
	<4F45638B.30305@fb.com>
	<4F45742F.1070605@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com
To: asharma@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F45742F.1070605@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arun Sharma <asharma@fb.com>
Date: Wed, 22 Feb 2012 15:03:11 -0800

> Turns out that we had a /sbin/ifup-local that deleted all the routes
> including default gw and populated the route afresh.
> 
> route del default gw ...
> ip route | grep -v scope | awk '{print $1}' | while read route; do ip
> route flush $route; done
> 
> This worked fine with fib_hash, but breaks with fib_trie. I'll
> investigate why this was done and look for a workaround if possible.

It breaks because that script sequence quoted above depends upon the
order in which the routes are listed.  Since fib_hash and fib_trie use
different datastructures, the order in which route entries are dumped
will not be the same and this is completely unavoidable.

You therefore must not, and can not, have scripts which have such a
dependency.
