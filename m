From: Roger Luethi <rl@hellgate.ch>
Subject: [0/3] mc_filter on big-endian arch
Date: Sun, 6 Jun 2004 18:53:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040606165322.GA13247@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A.J. from VIA Networking Technologies noticed that via-rhine is using
cpu_to_le32() when preparing mc_filter hashes. I confirmed that this
breaks Rhine hardware multicast filters on big-endian architectures.

A bunch of other drivers are affected, too. I'll post a patch for
2.6 atp, winbond, and tulip_core (typhoon could be okay at first
glance). Those are entirely untested due to lack of hardware.

If the patches are ack'ed by the respective maintainers, we might want
to fix up the tulips in 2.4 as well. atp still uses set_bit in 2.4 and
is thus okay. Note: Although it's been widely popular, there is no need
to use cpu_to_le32 when converting from set_bit.

A generic hash filter calculator might be helpful. Most drivers get
it right, but the workings of the hardware mc filters and the bit
trickery in all those functions calls for at least one _documented_
version. IMHO, anyway.

Roger
