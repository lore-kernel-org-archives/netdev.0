From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH] net: inet_diag: export IPV6_V6ONLY sockopt
Date: Sun, 21 Jun 2015 03:47:39 +0200
Message-ID: <20150621014739.GA18664@orbit.nwl.cc>
References: <20150615205421.GA22616@orbit.nwl.cc>
 <1434716132-25103-1-git-send-email-phil@nwl.cc>
 <1434721920.31511.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:40036 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753463AbbFUBrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 21:47:42 -0400
Content-Disposition: inline
In-Reply-To: <1434721920.31511.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2015 at 06:52:00AM -0700, Eric Dumazet wrote:
> On Fri, 2015-06-19 at 14:15 +0200, Phil Sutter wrote:
> > For AF_INET6 sockets, the value of struct ipv6_pinfo.ipv6only is
> > exported to userspace. It indicates whether an unbound socket listens on
> > IPv4 as well as IPv6.
> 
> What is an 'unbound socket' ??? This makes no sense to me here.

Indeed, this is just plain wrong. Actually meant "not bound to a
specific IPv6 address".

> >  Since the socket is natively IPv6, it is not
> > listed by e.g. 'netstat -l -4'.
> 
> netstat does not use this interface. iproute2/ss does.

Just used this as a simple example illustrating the problem, but doing
the same with 'ss' is truly a better choice.

[...]

> 1) This certainly should not compile on current linux trees.
>    Always submit such patches on net-next.

It cleanly applies to net.git.

> 2) It is not clear why we would add this attribute if it is 0.
>     This looks a waste of data.
> 
> So I would rather use :

ACK. Thanks for reviewing, v2 follows after I've tested it.

Cheers, Phil
