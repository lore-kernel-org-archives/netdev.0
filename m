From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Mon, 2 Feb 2004 13:47:56 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0402021316110.6508-100000@blackhole.kfki.hu>
References: <Pine.LNX.4.58.0402021146370.5347@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.58.0402021146370.5347@sorbus2.navaho>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Feb 2004, Steve Hill wrote:

> On Mon, 2 Feb 2004, Jozsef Kadlecsik wrote:
>
> > Yes, once, on the whole packet. Or do you see the message two times, when
> > issuing the ping command above once?
>
> No, only once for the whole packet (sorry, I think I didn't do a good job
> of describing the problem).
> init_conntrack() always gets called once for the whole packet (this seems
> right to me).  However, destroy never gets called for the whole packet if
> the packet was fragmented, which seems to be  the source of the leak -
> init_conntrack was called and allocated for the whole packet but that
> memory is never freed again if the packet was fragmented.

To be precise, the destroy function is not called whenever a packet leaves
the system: it gets called, when conntrack thinks the connection is
completed. It can happen when whe explicitly know from the packet that it
finishes the connection (ICMP reply for ICMP non-error messages, and a
special case for TCP RST), or when the timer of the conntrack entry goes
off.

So the destroy function is called when the system sees the ICMP reply
packet from machine 3 (and there were so many request as reply packets so
far) - otherwise it'll simply time out the connection.

Machine 3 answers the ping requests, doesn't it? You ping the same IP
address all the time?

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
