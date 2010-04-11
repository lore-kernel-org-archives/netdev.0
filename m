From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 02:04:11 +0300
Message-ID: <201004120204.11405.nuclearcat@nuclearcat.com>
References: <201004112338.47019.nuclearcat@nuclearcat.com> <1271025353.2078.155.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41880 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155Ab0DKXFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 19:05:54 -0400
In-Reply-To: <1271025353.2078.155.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It is IMHO not safe, because route for this socket might have just
> changed and we are transmitting an old packet (queued some milli seconds
> before, when route was different).
> 
> We then memorize a queue_index that might be too big for the new device
> of new selected route.
> 
> Next packet we want to transmit will take the cached value of
> queue_index, correct for old device, maybe not correct for new device.
Yes, it is possible, i have there RIP with 1k+ routes, changing non-stop.

> 
> You could try to revert commit a4ee3ce3293dc931fab19beb472a8bde1295aebe
> 
> commit a4ee3ce3293dc931fab19beb472a8bde1295aebe
I will try to revert it now. But to trigger bug probably i need 1-2 days.

