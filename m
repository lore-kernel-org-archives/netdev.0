From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 1/4] [NETLINK]: Handle NLM_F_ECHO in netlink_rcv_skb()
Date: Fri, 11 Aug 2006 19:35:49 +0400
Message-ID: <20060811153549.GA16351@ms2.inr.ac.ru>
References: <20060809204821.216122988@postel.suug.ch> <20060809205439.434010049@postel.suug.ch> <20060810155120.GA494@ms2.inr.ac.ru> <20060810190210.GH14627@postel.suug.ch> <20060810203252.GA6414@ms2.inr.ac.ru> <20060810211833.GK14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:48297 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932127AbWHKPgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 11:36:08 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060810211833.GK14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> I get your point and I see the value. Unfortunately, probably due to
> lack of documentation, this feature isn't used by any applications I
> know of.

Well, tc was supposed to use it, but this did not happen and
it remained deficient.


> We even put in the hacks to make identification of own caused
> notifications easier by storing the netlink pid of the originator in
> the notification message.

Actually, it was supposed to be done everywhere, but originator info
did not propagate deep enough in many cases, especially in IPv6.
So, this is not a hack, it is a good work. :-)


BTW I have just remembered why it was especially important,
this should be documented as well.

Each socket, which subscribes to multicasts becomes sensitive
to rcvbuf overflows. F.e. when you do control operations on a socket,
which is subscribed to multicasts, the response can be lost in stream
of events and -ENOBUFS generated instead. If it is a daemon, it can resync
the state, but if it is a simple utility, it cannot recover.

Probably, unicasts sent due to NLM_F_ECHO should somehow override
rcvbuf limits.

This reminded me about a capital problem, found by openvz people.
Frankly speaking, I still have no idea how to repair this, probably you
will find a solution.

Look: while a dump, skb allocation can fail (because of many reasons,
the most obvious is that rcvbuf space was eaten by multicasts).
But error is not reported! Oops. The worst thing is that even if an error
is reported, iproute would ignore it.

Alexey


