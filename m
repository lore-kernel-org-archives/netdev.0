From: Mark Borst <mark@borst.org>
Subject: Re: node-local multicast issues
Date: Wed, 10 Nov 2004 16:17:31 +0200
Message-ID: <1100096251.22964.7.camel@mn-2>
References: <OF18E2258F.5E2E252A-ON88256F47.007FA9FD-88256F47.0080590C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hessu@cs.tut.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF18E2258F.5E2E252A-ON88256F47.007FA9FD-88256F47.0080590C@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-11-09 at 15:21 -0800, David Stevens wrote:
>         The loopback device doesn't have IFF_MULTICAST set, so technically
> it is not a multicast-capable device, and you shouldn't be able to join a 
> group on it. 

That is Linux-specific, right? At least KAME's 'lo' does support
multicast, and their README says: 

Each interface joins the solicited multicast address and the
link-local all-nodes multicast addresses (e.g.  fe80::1:ff01:6317
and ff02::1, respectively, on the link the interface is attached).
In addition to a link-local address, the loopback address (::1) will be
assigned to the loopback interface.  Also, ::1/128 and ff01::/32 are
automatically added to routing table, and loopback interface joins
node-local multicast group ff01::1.

On Windows I don't see 'lo' joining ff01::1.

RFC 3513 tells me:

2.7.1 Pre-Defined Multicast Addresses

    All Nodes Addresses:    FF01:0:0:0:0:0:0:1
                              FF02:0:0:0:0:0:0:1

   The above multicast addresses identify the group of all IPv6 nodes,
   within scope 1 (interface-local) or 2 (link-local).

Does that imply that the linux stack doesn't conform to RFC 3513?

> I think the way it ought to work is that you join the group on any device, 
> with IPV6_MULTICAST_LOOP set and local guys should hear the node-local 
> multicasts, but it shouldn't be sent on the wire. Multicasting could be supported on 
> loopback, too, but it doesn't matter all that much unless there are no multicast-capable 
> real devices.

>         However, it appears that node-local multicasts are being sent out 
> the device, at least on an early 2.6 kernel I did a quick test with. There probably 
> isn't anything enforcing the node-locality in the send path, which I would consider a 
> bug. :-)

Even more interesting: an other node responded to 'ping6 ff01::1' so
there is some bug somewhere ;)

On another note: 'ping6 ff02::1' gives "connect: Invalid argument" on
linux. On KAME it says "ping6: UDP connect: Network is unreachable". The
only implementation that gives me replies is Solaris. This also sounds
like a bug to me.

Regards,
-- 
Mark Borst
Researcher
Network and Protocols Group
Tampere University of Technology, Finland
