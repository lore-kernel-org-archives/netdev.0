From: David Woodhouse <dwmw2@infradead.org>
Subject: IPv6 6to4 on site-local networks.
Date: Wed, 10 Sep 2003 19:38:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063219081.7869.205.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm looking at the possible ways of setting up a IPv6 site-internal
network, given the prior existence of IPv4 tunnels on RFC1918 addresses
between various physical sites.

The idea which looks sanest to me is to use the 6to4 automatic
tunnelling trick. Instead of 2002::/16, however, we use fec0::/16. Since
our internal IPv4 addresses are in the 172.16/12 range, we end up with
fec0:ac10::/28 for the internal site-scope addresses.

This requires a hack to sit.c -- just a single s/0x2002/0xfec0/ in fact.
I'd like to make that configurable somehow. Any ideas on how best to do
it?

With this in place, individual routers can still run radvd and route to
native IPv6 on their own fec0:ac1x:xxyy::/48 subnets -- just as we do in
the real world with 6to4 on 2002:xxxx:yyyy::/48. 

--

A separate and only vaguely-related question: how separate are
site-scope and global-scope addresses and routes?

Following the above configuration, we have site-scope addresses in the
fec0:ac10::/28 range, and a route to that network via the tunnel. This
goes over the RFC1918 IPv4 internal addresses, across CIPE tunnels etc.
between offices.

For IPv6 connectivity to the _outside_ world, can it really be done as a
completely orthogonal issue? A machine in each location can have a
'real' IPv6 link, and run radvd accordingly, advertising the _global_
addresses obtained by either a tunnel or 'real' 6to4. 

In the presence of two hosts broadcasting router advertisements, one
with site-scope addresses and the other with global-scope addresses,
will Linux do what I'd want?


-- 
dwmw2
