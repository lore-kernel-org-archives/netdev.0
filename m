From: David Woodhouse <dwmw2@redhat.com>
Subject: Missing routes cause BUG() in icmpv6_xmit_lock().
Date: Sun, 31 Aug 2003 15:56:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062341789.2785.11.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Kernel is Red Hat 2.4.21-20.1.2024.2.1.nptlsmp from the Severn beta.
Triggered as follows:

Configure 6to4 IPv6 address 2002:X:Y::1 on the ISDN dialup.

Enable IPv6 forwarding on all interfaces

Configure radvd to advertise 2002:X:Y:1234::/64 on internal eth0 device
Observe radvd doesn't add any routes for the 2002:X:Y:1234::/64 subnet. 
Bring up an internal machine on eth0.
Observe it receive an IPv6 address of the form 2002:X:Y:1234:.....

Attempt to ping6 a machine in the outside world from the internal host.
Observe that reply packets from the outside world to the internal
address are routed straight back _out_ the 6to4 tunnel again, in the
absence of sane routes -- with associated bitching...
	redirect: no link_local addr for dev
	Dead loop on virtual device tun6to4, fix it urgently!

Attempt to ping6 the router 2002:X:Y::1 from internal host.
Observe panic: http://www.linux.org.uk/~dwmw2/dcp_1575.jpg

Should initscripts set up an unreachable route for 2002:X:Y::/48 when
setting up a 6to4 tunnel? Should radvd set up routes to subnets of that
network when advertising them internally according to its configuration?

Certainly the kernel should do something other than panicking :)

-- 
dwmw2
