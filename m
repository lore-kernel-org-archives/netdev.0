From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: Re: [PATCH] ipv4 tcp autobind problem
Date: Tue, 30 Sep 2003 16:37:48 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309301237.QAA01426@yakov.inr.ac.ru>
References: <20030930024320.5aca8ddc.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, hidden@balabit.hu, netdev@oss.sgi.com,
        linux-net@vger.rutgers.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030930024320.5aca8ddc.davem@redhat.com> from "David S. Miller" at Сен 30, 2003 02:43:20 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> in inet_sendmsg() is that when an RST is received, sk->num is set to zero, 

Yes, I remember this. This funny thing was added to avoid using reserved
ports obtained from accept() to do connect(). Before that sockets were never
unbound after they bound once exactly to avoid weirdness of the kind
descibed in your mail, but this happened to be insecure.

>From this mail I still do not see why autobinding of void socket is so
bad thing, that it requires marginal fixing at the place which is already
marginal. What is the real problem? So, bad sendmsg() selects some port as
a side effect. It makes it on udp and tcp. What is the deal? If it is disaster
for tcp, why it is not bad for udp?


> local port (sk->sport) remains unchanged until the socket is closed.

Socket is _closed_. Local port is reset only after socket is closed,
unless PORT_USERLOCK is set. And sk->sport remains unchanged even
after socket is closed, btw, so... 

I do recognize that current behaviour is weird, but I still want to know
how this marginal weirdness escaped to be seen in reality.

Alexey
