From: Russell King <rmk@arm.linux.org.uk>
Subject: ip -6 route shows incorrect route expiry times
Date: Sun, 30 Jan 2005 16:08:40 +0000
Message-ID: <20050130160840.C25000@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This looks like a unit conversion error, spotted in Red Hat FC2.
On it's own, it doesn't look like there's anything wrong, until
you look at two copies of the output 10 seconds apart:

rmk@dyn-67:[bk]:<1030> /sbin/ip -6 route; sleep 10; /sbin/ip -6 route
default via fe80::a00:2bff:fe95:1d7b dev eth0  proto kernel  metric 1024
  expires 169sec mtu 1500 advmss 1440
default via fe80::a00:2bff:fe95:1d7b dev eth0  proto kernel  metric 1024
  expires 168sec mtu 1500 advmss 1440

It appears that the expiry seconds here are actually in units of
10 seconds.  Maybe someone's double-converting kernel Hz to user Hz?

-- 
Russell King
