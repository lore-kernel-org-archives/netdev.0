From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs copy_to_user].
Date: Thu, 11 May 2006 12:30:35 +0400
Message-ID: <20060511083031.GA12712@2ka.mipt.ru>
References: <20060508122418.GA22554@2ka.mipt.ru> <20060510.125848.44052388.davem@davemloft.net> <20060511064037.GB22770@2ka.mipt.ru> <20060511.000721.60889163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:3740 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030188AbWEKIbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 04:31:09 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060511.000721.60889163.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 11, 2006 at 12:07:21AM -0700, David S. Miller (davem@davemloft.net) wrote:
> You can test with single stream, but then you are only testing
> in-cache case.  Try several thousand sockets and real load from many
> unique source systems, it becomes interesting then.

Route lookup is _additional_ cost for the system, but, as far as I
understand, netchannels are supposed to help with data processing, not
with destination point selection. It must have route lookups,
socket(netchannel) lookups, they just will be in other place.

I can test system with large number of streams, but unfortunately only
from small number of different src/dst ip addresses, so I can not
benchmark route lookup performance in layered design.

> From profiles of heavily used web server, what shows up is bulk of cpu
> being in socket demux and tcp_ack().  Next bubble is routing cache.
> I have not seen good profiles from a heavy web server employing any
> real use of netfilter, that would be interesting as well.

I have several oprofiles of static test web server which does 2.5k
requests/sec with about 3000 sockets created/removed per second. All
connections are very tiny.
Machines are in LAN, so no heavy route lookups, but socket lookup is quite
heavy. The most heavyweight network function is tcp_v4_rcv() (number 15),
next one is __alloc_skb() (25'th place), __kfree_skb() (35'th place).
netif_receive_skb() at 63, ip_rcv() - 80'th place.
tcp_ack() at 99. No *inet_lookup at all.
I do understand that it is synthetic benchmark, but it is not so rare
usage case.

-- 
	Evgeniy Polyakov
