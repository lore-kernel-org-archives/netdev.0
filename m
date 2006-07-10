From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannels: progress report. Sending benchmark.
Date: Mon, 10 Jul 2006 17:32:45 +0400
Message-ID: <20060710133244.GA32193@2ka.mipt.ru>
References: <20060608171555.GA10273@2ka.mipt.ru> <20060613173321.GA648@2ka.mipt.ru> <20060629093801.GA6049@2ka.mipt.ru> <20060710132321.GA585@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:4293 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S964965AbWGJNct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 09:32:49 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060710132321.GA585@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 10, 2006 at 05:23:21PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> After week vacations I'm pleased to announce following progress report.
> 
> Numbers for small packets (80 bytes) bulk sending:
> 
>  * netchannel: 57 MB/sec, ~80% CPU usage
>  * socket: 22 MB/sec, ~90% CPU usage
> 
> Receiving side is netcat server, which dumps received data into
> /dev/null
> 
> Actually it is not 100% correct to call that results correct, since 
> it uses hackish optimisations, which can lead to broken behaviour for 
> non-bulk transfers or transfers over bad lines. If some of them are
> removed, speed drops to 54 MB/sec for 80 bytes packets, and if socket
> analog for NODELAY flag is set, i.e. each packet is immediately being
> sent when it has been written, speed drops down to 16 MB/sec (socket
> with SO_NODELAY was not tested though).

I mean TCP_NODELAY.
Socket code uses nonblocking mode and epoll.

-- 
	Evgeniy Polyakov
