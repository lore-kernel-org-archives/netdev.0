From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: TProxy, 2.4 Kernel and NetFilter
Date: Wed, 11 Feb 2004 20:58:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211195838.GA11552@sch.bme.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Henrik Nordstrom <hno@marasystems.com>,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jambunathan Kalyanasundaram <k_jambunathan@yahoo.co.uk>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


  Hi,

On Wed, Feb 11, 2004 at 08:49:33AM +0100, Henrik Nordstrom wrote:
> > 2) But if I am not really interested in the overheads
> > imposed by the NetFilter, the only option is to patch
> > the Linux kernel with Balazs Scheidler's patch.
> 
> Not sure this has less overhead.

  I'm sure it hasn't. TProxy was never intended to be a "faster redirect",
or something like that. If you do not care about almost full transparent
proxying, you don't need TProxy at all.

  The TProxy patch can be used to make the proxy transparent from both
sides: the client sends the packets to the server's IP, and the server
sees packets coming from the client's IP. However, this needs user-space
support in the proxy itself. And Gianni Tedesco's latest TProxy support
patch for Squid is known to be broken...

> > If I don't like something as heavyweight as Netfilter
> > and something that is as  "non standard" as patching
> > the kernel, are there any ways out ? 
> 
> Yes, by configuring the client to use the proxy.

  Completely true. This is _the_ way to go if you can set all clients to
use the proxy.

> If it is a normal Internet proxy environment where the number of clients 
> are limited, and the proxy supports per-user selection of the outgoing 
> address (Squid does) then it is possible with the help of NAT.
> 
> 1. Set up as many IP aliases on the proxy server as you have clients. Use
> one of the unassigned networks.
> 
> 2. Configure the proxy to use one IP alias per client IP address.
> 
> 3. Configure iptables NAT rules in OUTPUT to NAT these IP aliases back to
> the client IP address.

  Hmm... What a solution! :)

> If it is a reverse proxy or other environment where the client addresses 
> are not limited then this obviously can not be done and you must use the 
> tproxy patch.

  As I wrote, the patch for Squid would need some fixes before actually
using it... Unfortunately I don't know enough about Squid to be able to
make those fixes.

-- 
 KOVACS Krisztian
