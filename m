From: Ben Greear <greearb@candelatech.com>
Subject: Re: Interconnect virtual device?
Date: Mon, 28 Feb 2005 09:24:25 -0800
Message-ID: <422353C9.6050001@candelatech.com>
References: <4222A8F2.6080004@candelatech.com> <1109592365.2188.914.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1109592365.2188.914.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2005-02-28 at 00:15, Ben Greear wrote:
> 
>>Hello!
>>
>>I am considering writing a kernel module to provide a very
>>simple virtual interface.  This interface would be attached
>>to another interface, and would not be directly associated with
>>hardware.  It can have IP addresses & routing tables, and in
>>almost every way appear to be a regular ethernet interface.
>>
>>The idea is that when you tx on this virtual interface, it
>>will cause a packet to be received on another interface.  And,
>>when a packet is received on the interface, it will tx on the
>>other interface.
>>
> 
> 
> In other words, it redirects to another device - I take it based on some
> rules. Sounds to me like the mirred action already does this (and in
> addition can mirror).

Actually, I was thinking that either user-space or perhaps a kernel
module could use the standard methods of receiving all pkts in promisc
mode to do the bridging portion.  If I force the real ethernet
interface to have no IP address, and put it into promisc mode, then
I can effectively bridge in user-space.

When I re-insert the pkts into the stack by writing to the virtual
device, the (potentially modified) packet can be
routed and firewalled, etc just like a normal packet received from the
network.  I may need to have two virtual inter-connects, one w/out
an IP that does the bridging portion, and one with an IP that actually
communicates with the rest of the kernel.  In this case, the two virtuals
would be connected to each other.

I think this could provide a way to do very customized actions on
raw packets without having to hack the kernel on an ongoing basis.


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
