From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: Conntrack leak (2.6.2rc2)
Date: Mon, 2 Feb 2004 10:22:17 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0402021016450.6508-100000@blackhole.kfki.hu>
References: <Pine.LNX.4.58.0402020854160.4039@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.58.0402020854160.4039@sorbus2.navaho>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Steve,

On Mon, 2 Feb 2004, Steve Hill wrote:

> However, if I start a connection with a fragmented packet (i.e. my MTU
> is 1500 bytes, so "ping -c 1 -s 2500 172.16.0.1" sends a packet consisting
> of 2 fragments), init_conntrack() is called as usual, but when the session
> is timed out destroy_conntrack() never gets called.  This means that the
> memory for the connection is never freed and ip_conntrack_count is never
> decremented.  However, the connection is still removed from the hash
> table.  This means that it leaks memory, and eventually reaches
> ip_conntrack_max and starts dropping new connections.

init_conntrack is called only when we have full, non-fragmented
packets: ip_conntrack_in explicitly calls the proper function to gather
the fragments before calling init_conntrack. There is no memory leak
there.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
