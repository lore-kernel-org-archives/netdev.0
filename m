From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Wed, 12 Jan 2005 14:42:49 -0800
Message-ID: <41E5A7E9.4030101@candelatech.com>
References: <20050112222437.GC14280@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org, rhousley@rsasecurity.com,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050112222437.GC14280@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> Hi,
> 
> After struggling with various userland VPN solutions for a while (and
> failing to make IPSEC tunnel mode do what I want), I decided to just
> implement ethernet-in-IP tunneling in the kernel and let IPSEC transport
> mode handle the rest.
> 
> There appeared to be an RFC for ethernet-in-IP already, RFC 3378, so I
> just implemented that.  It's very simple -- slap a 16-bit header (0x3000,
> which is 4 bits of etherip version number and 12 bits of padding) onto
> the beginning of the ethernet packet, and then wrap it in an IP packet.
> 
> Below is what I came up with, against the latest Fedora Core 3 kernel,
> which is 2.6.10-something.  It survives some fairly basic testing between
> a number of different machines, UP and SMP.  (Corresponding iproute2
> patch is available from http://www.wantstofly.org/~buytenh/etherip/ )
> 
> Notes:
> - daddr=0 tunnel mode is meaningless for generic ethernet tunneling,
>   so I didn't implement that.  Packets are just dropped on the floor
>   if daddr==0 at the time of sending, which is the default mode for
>   the etherip0 device.
> 
> Issues and TODO:
> - Implement MULTICAST(daddr) tunnel mode, seems useful to have.
> - Perhaps we should always present a MTU=1500 device to the user and
>   deal with fragmentation issues ourselves.
> - Don't take TTL of outer packet from inner packet.
> - Figure out what to do with DF.
> - Check whether ECN bits are correctly {en,de}capsulated.
> - Check out iffy-looking '2 * sizeof(struct etheriphdr)' construct
>   (same problem in ip_gre.c?)
> 
> Comments?  I would like to see this upstream when the remaining issues
> have been sorted out.

Why do you add a single device when loading the module?  Is this just
so you have something to hook the ioctl to?

My personal preference would be something where you do not automatically
create an etherip0, but would have an etherip-config tool or similar to
create/destroy interfaces.

Also, could you add an ioctl that allowed one to query whether or not
a particular device is an etherip device?  I had always wished I had added
this earlier to the VLAN code :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
