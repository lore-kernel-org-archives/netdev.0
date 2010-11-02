From: Arnd Hannemann <arnd@arndnet.de>
Subject: Re: Routing over multiple interfaces
Date: Tue, 02 Nov 2010 23:10:53 +0100
Message-ID: <4CD08C6D.1090107@arndnet.de>
References: <1288645922.5977.41.camel@macbook.infradead.org> <20101101.141638.116372747.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org, uweber@astaro.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slowhand.arndnet.de ([88.198.19.76]:46281 "EHLO mail.unitix.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751761Ab0KBWK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Nov 2010 18:10:58 -0400
In-Reply-To: <20101101.141638.116372747.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 01.11.2010 22:16, schrieb David Miller:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Mon, 01 Nov 2010 17:12:02 -0400
> 
>> But when I do a large upload, I find that the kernel is only ever using
>> a *single* link at a time, rather than both. How can I make it use
>> *both* links? It's fine to confine each flow to a single link if it
>> doesn't saturate that link... but once the queue is full, it should
>> overflow onto the other device.
> 
> Once a TCP socket gets a routing cache entry, that's what it uses
> for the rest of the life of the connection.
> 
> The multi-pathing decision happens at the time the routing
> cache entry is created.

You should be able to come a solution with netfilter (probably not so efficient):

iptables -t mangle -A PREROUTING -d $EXTERNAL -m statistic --mode nth --every 2 -j MARK --set-mark 6
ip rule add fwmark 6 table ppp1
ip route replace $EXTERNAL via $PPP0GW
ip route replace $EXTERNAL via $PPP1GW table ppp1

Regards,
Arnd
