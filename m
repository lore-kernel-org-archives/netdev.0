From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Sun, 23 Sep 2012 20:13:54 +0200
Message-ID: <1348424034.2669.1806.camel@edumazet-glaptop>
References: <1348242511.2669.635.camel@edumazet-glaptop>
	 <20120921.122705.1344923255084267186.davem@davemloft.net>
	 <alpine.LNX.2.01.1209231446170.9625@nerf07.vanv.qr>
	 <20120923.121601.2244503178301624422.davem@davemloft.net>
	 <alpine.LNX.2.01.1209231930520.3904@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	subramanian.vijay@gmail.com, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:65444 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754408Ab2IWSN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2012 14:13:58 -0400
Received: by eekc1 with SMTP id c1so2039065eek.19
        for <netdev@vger.kernel.org>; Sun, 23 Sep 2012 11:13:57 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.01.1209231930520.3904@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-09-23 at 19:40 +0200, Jan Engelhardt wrote:

> 
> Cache sizes, and an oddity.
> 
> L1 cache sizes have not increased ever since (the 2011 Intel i7-2600
> has the same amount of L1 as a 1998ish AMD K6-2), and the Atom N450
> even has less, namely 24d+32i, meaning a 13000ish MTU might be more
> accurate for netbooks of this kind.
> 

MTU above 64K is not really useful, at least for IPv4, I think.

> What would a MTU of 64K buy? Offloading seems pointless for the lo
> device. There is no hardware to offload it to - well, the
> machine already has the packet too.

It buys 25% increase of performance. Not too bad...

I yet have to make sure no adjustment is needed, in TCP stack for
example.

If you try to change lo mtu on an old kernel (eg 2.6.38, on my laptop),
you can notice some packets drops (TCPBacklogDrop)
