From: Zdenek Radouch <zdenek@rcn.com>
Subject: need help with ip_output
Date: Sat, 26 Feb 2005 09:12:42 -0500
Message-ID: <3sp35g$62ejk@smtp04.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I am stuck designing a net driver that sits on top of a module performing
physical
routing layer.  The lower layer must switch (route) the outgoing packet to
the appropriate physical channel on the same interface. The physical layer
does not
use an address resolution protocol, the destination physical address is
computed
dynamically from the next hop IP address.

I am coming from BSD-style stacks, where the ip output actually carries the
next
hop IP address.  So there, the code looks [simplified API] something like
this:

stack code:
	output(pkt, dst_ip_addr)

net driver code:
output(pkt, dst_ip_addr)
{
	dest_hw_addr = hw_rt_resolve(dst_ip_addr)  // dynamically compute phys
dest addr
	fill_hw_header(pkt, dst_hw_addr) // fill phys layer header
	hw_tx(pkt)	// enqueue pkt for transmission in the lower phys layer module
}

Now the problem.
I can't figure out how to get hold of the destination IP address (next hop)
during the output processing!

None of the linux netif docs suggests how to do this, but maybe I am
missing something.
It appears to me that the Ethernet ARP paradigm drives the design of the
stack, but
I need to implement a general, non-protocol but dynamic address resolution
mechanism.

Conceptually, I need something like the hard_header() method, except it
would have
to pass down the IP address, rather than the phys address as it does now.
Alternately, if the next hop IP address is somewhere in the skb (there's a
undocumented
"dst" field;could it be there?), I could fish it out of there.

I'd appreciate any pointers to either what I've missed, or how this could
be implemented.
Thanks.

-Zdenek




