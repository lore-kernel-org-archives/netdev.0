From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Thu, 27 Jul 2006 00:48:48 +0200
Message-ID: <20060726224848.GX14627@postel.suug.ch>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.495778268@postel.suug.ch> <20060726.153949.29046809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:2999 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751238AbWGZWs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 18:48:27 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060726.153949.29046809.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2006-07-26 15:39
> Wow, were we corrupting the IP6CB() of input packets on every
> route lookup that hit this path?

I found that via compile error as passing on skb to this context
didn't make sense when I rewrote the code around it :-)

Fortunately it's only used read-only when notifying to figure
out the destination pid but that code seems bogus as well and
we can probably remove the netlink cb passing hell throughout
all the code there.

