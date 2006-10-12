From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 14:53:43 +0400
Message-ID: <20061012105343.GB17891@2ka.mipt.ru>
References: <200610121038.18309.dada1@cosmosbay.com> <000201c6ede7$0ef3e110$1a04010a@V505CP> <20061012103102.GA17891@2ka.mipt.ru> <200610121239.30823.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Martin Schiller <mschiller@tdt.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50568 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751258AbWJLKxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 06:53:54 -0400
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <200610121239.30823.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2006 at 12:39:30PM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > You should break your decision into per state change transformations.
> > I think it is possible with either conntrack or netlink module Samir
> > Bellabes <sbellabes_mandriva.com> creates (Network Events Connector
> > subject) or even using syncookie algo changes.
> 
> Hum.. they are some cases where conntrack is not an option (way too expensive 
> if your server handle XXX.XXX concurrent tcp streams)

I think any netlink related work here can not be used for any kind of
high performance setup - it will be too slow to send/receive one or more
messages per state change for each new connection...

> > But it will drastically change your server performance...
> 
> Sure, at least its capacity to answer to SYN packets (session establishment 
> should be slower, unless the thread receiving/handling SYN packets has 
> realtime scheduling)

Maybe it will be better to create some more complex protocol which will
collect data before sending netlink message, or just use a procfs file
or syscall/ioctl/socket option.

> Eric

-- 
	Evgeniy Polyakov
