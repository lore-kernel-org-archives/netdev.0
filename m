From: Mark Borst <mark@borst.org>
Subject: node-local multicast issues
Date: Tue, 09 Nov 2004 12:21:40 +0200
Message-ID: <1099995700.21310.8.camel@mn-2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hessu@cs.tut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all

I am doing some experiments with node-local multicasting as a means of
inter-process communication. I am using debian unstable with linux
kernel 2.6.8 with MIPL 2.0 patches. Now I am running into some problems.

I want to keep the node-local packets on the 'lo' interface. I do that
by setting socket option IPV6_MULTICAST_IF to the 'lo' ifindex. Then I
use sendmsg() to send the message. As a result I get the error "Network
is unreachable". When I started analyzing it, I found the following:

The default routing table in my system includes this route:

ff00::/8	::	U     256    0        0 eth0

There is no route for this to 'lo'. Which makes all attempts to send
nodelocal (ff01::/8) multicast packets to 'lo' go wrong. When I add the
following routes, it works:

ff01::/16	::	U     1      0        0 eth0
ff01::/16	::	U     1      0        0 lo

When I don't use IPV6_MULTICAST_IF, the packets get sent to 'eth0', but
when I set it to 'lo' the packets get sent to 'lo'. So far so good.

The next thing I notice is that I see the ff01::/8 packets on eth0 with
ethereal. Does that mean that they are actually sent out on the wire? If
so, then this would violate the semantics of nodelocal multicast.

So the question rises: what is the intended behaviour here? As I
understand it, ff01::/8 traffic is interface local, and you should use
IPV6_MULTICAST_IF to select which interface you want to use. Traffic
sent to ff01::/8 on 'eth0' will not be seen on 'lo'. This is however
prevented by not having a route to 'lo'. Should these routes be set per
interface by default?

Please enlighten me.

Regards,

-- 
Mark Borst
Researcher
Network and Protocols Group
Tampere University of Technology, Finland
