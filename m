From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Wed, 22 Jan 2014 06:32:36 -0800 (PST)
Message-ID: <1390401156.61208.YahooMailBasic@web125501.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm41.bullet.mail.ne1.yahoo.com ([98.138.120.48]:44695 "EHLO
	nm41.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755695AbaAVOfW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 09:35:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

> Actually, I was alerted by reset processing in your patch, it cannot be right.

Perhaps, I missed something.

My tests were:
1) enable anycast in tcp_v6_conn_request().
So, a client-serveur exchange with anycast destination address is possible.

2) try to connect with a port not listen by the server.
With unicast destination address, the client got a reset.
With anycast destination address, no reset, the client try several syn and give up.

3) enable anycast in tcp_v6_send_reset().
With anycast destination address, the client got a reset.
So unicast and anycast behave the same.

Do you see any problem with this behaviour ?

> Do not you think this must not be enabled for common use? At least
> some separate sysctl disabled by default.

We could indeed use a sysctl, disabled by default.

But my goal was to enable anycast address usage transparently, if possible.

It's only a possibility for some use cases and if it's dont break unicast TCP usage,
like I think it, I propose to enable this change without sysctl.

So, my proposals for the TCP case, in descending order of preference are:

1) No sysctl.
2) A sysctl disabled par default, used in tcp_v6_conn_request() and tcp_v6_send_reset().
3) A sysctl disabled par default, used in tcp_v6_send_reset(), if problem only here.

Greetings,
Francois-Xavier
