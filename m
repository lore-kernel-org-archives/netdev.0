From: Brian White <bcwhite@precidia.com>
Subject: rp_filter dropping things it shouldn't
Date: Wed, 05 Nov 2003 15:41:02 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FA9605E.2876B0D5@precidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kernel:	2.4.20
Arch:	i386
Dist:	debian/testing

While experimenting with an automatic dial-backup system, we ended up with
the situation where we have two default routes, one to PPP with a metric
of 0 and one to ethernet with a metric of 1.  The PPP route is brought
on-line when connectivity to a remote host is not possible over ethernet
but the default route over eth0 needs to remain so we can continue to check
that link.

The problem is that when we bind to eth0 to ping the remote host and a
reply does come back (thus indicating we can close the dial-backup link),
the ping reply is getting dropped by "rp_filter".

My guess is that rp_filter sees that the preferred default route is over ppp0
and thus assumes that packets should not be coming over eth0, which of course
they do since that is the interface/address the request was sent from.

Setting "rp_filter" to "0" for "eth0" fixed this problem.

                                          Brian
                                 ( bcwhite@precidia.com )

-------------------------------------------------------------------------------
 "A dollar saved is two dollars earned."  -- Dave Chilton (The Wealthy Barber)
