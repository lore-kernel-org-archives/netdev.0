From: Andreas Jellinghaus <aj@dungeon.inka.de>
Subject: ipsec / pppoe
Date: Sun, 1 Jun 2003 12:33:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306011233.22544.aj@dungeon.inka.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: howto@lartc.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

with pppoe it is usualy necessary to clamp the maximum segment
size down to 1452 bytes. This can be done with a netfilter module
or with "-m 1452" option to pppoe.

with ipsec (esp, tunnel mode) even on a wlan interface before
the ppp connection I needed to clamp the mss down further
to 1384 bytes. now all connections are working fine.

my calculation gave me
1500 mtu (wlan0) - 20 (ip) - 48 (esp) - 20 (ip) - 20 (tcp) = 1392
or 1492 (ppp(oe)) - 20 (ip) - 20 (tcp) = 1452,
so the min of 1392 should have been the right value.

Don't know why I need to clamp the mss down to 1384,
but e.g. http connections to www.microsoft.com work
fine with 1384 and do not work at all with 1392.

still I don't know why some machines don't respond to
icmp packet to big errors with a smaller packet but not
act on it at all. maybe some broken firewall thinks it is
some kind of attack? I don't know what exactly is between
me and websites such as www.google.com or www.microsoft.com,
so I can't figure out.

sorry to have bothered everyone and many thanks to james for
his help. 

cc: to howto@lartc.org, it think this would make a nice
howto entry.

Regards, Andreas
