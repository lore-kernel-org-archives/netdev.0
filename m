From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: raw ipv6 broken in 2.4.19
Date: 12 Aug 2002 23:02:29 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1029186150.700.39.camel@tux>
References: <200208121920.XAA18870@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200208121920.XAA18870@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Mon, 2002-08-12 at 21:20, kuznet@ms2.inr.ac.ru wrote: 
> Hello!
> 
> > raw ipv6 doesn't work in 2.4.19,
> 
> Seems, more information is required because of:
> So, please, make binary tcpdumps and tell me version of iputils,
> which you use and make straces of ping.

I think I've narrowed it down to what's causing the problem now.
I didn't think far enough before.

It seems to be the tulip driver, if I use it things stop working but if
I use an old ISA ne2k clone it works fine.
The NIC is a D-Link DFE-570TX (quad tulip with "Digital DS21143 Tulip
rev 65" for those who don't know)

Both the tulip-driver in vanilla 2.4.19 (without NAPI patch) and the
tulip-NAPI-011103 driver causes this.

Sorry for pointing fingers at the ipv6 code, it was the most logical
solution for my brain (and the fact that I found something to back out
that made it work again :)

I think the strace and tcpdumps are uninteressing now so I'm not
attaching them, the tcpdump looked perfectly normal to me.
But here a small piece of the strace:

sendto(3, "\200\0\0\0\304\2\3\0Z\16X=\331%\17\0\10\t\n\v\f\r\16\17"..., 64, 0, {sin_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "3ffe:200:3d:1:2d0:b7ff:fe3f:b7b", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 64
recvmsg(3, 0xbfffea80, 0)               = -1 EHOSTUNREACH (No route to host)
recvmsg(3, 0xbfffe800, MSG_ERRQUEUE|MSG_DONTWAIT) = -1 EAGAIN (Resource temporarily unavailable)
write(2, "ping: recvmsg: No route to host\n", 32ping: recvmsg: No route to host
) = 32

I'm going to take a look at the driver now but I don't really know what
to look for.

-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
