From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/5] [IPV6]: Multiple Routing Tables
Date: Sat, 29 Jul 2006 13:13:06 +0900 (JST)
Message-ID: <20060729.131306.80352422.yoshfuji@linux-ipv6.org>
References: <20060726221100.325687073@postel.suug.ch>
	<20060726221849.495778268@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:18951 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1161440AbWG2ELl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 00:11:41 -0400
To: tgraf@suug.ch
In-Reply-To: <20060726221849.495778268@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20060726221849.495778268@postel.suug.ch> (at Thu, 27 Jul 2006 00:00:02 +0200), Thomas Graf <tgraf@suug.ch> says:

> Adds the framework to support multiple IPv6 routing tables.

Well, one design consideration that I have had for several months
is performance impact.

Previously, we directly use address, ifindex etc., not flowi,
in IPv6 routing code except for ip6_route_output().
This patch changes them to use flowi.
I know this should work and it is a good way for abstraction.
However, initializing flowi for IPv6 is more expensive than
one for IPv4, and it would result in poor performance (especially
without CONFIG_IPV6_MULTIPLE_TABLES).

Am I too cautious?
Should we eat this?

--yoshfuji
