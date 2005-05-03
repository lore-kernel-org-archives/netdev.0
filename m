From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bug 4554] New: /proc/net/route missing info for 127.0.0.1/8
Date: Wed, 04 May 2005 00:58:24 +0200
Message-ID: <42780210.2070607@trash.net>
References: <20050503143603.4d77d3dd@dxpl.pdx.osdl.net>	<4277FDFD.3040501@trash.net> <20050503154709.218626c6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050503154709.218626c6@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> It shows up on our 2.4.18 system, probably it got lost in the fib/seq_printf
> conversion.
> 
> $ /sbin/route -n
> Kernel IP routing table
> Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
> 192.168.159.0   172.20.4.11     255.255.255.0   UG    0      0        0 eth2
> 172.20.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth2
> 127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0 lo
> 0.0.0.0         172.20.0.1      0.0.0.0         UG    0      0        0 eth2

2.4.18 looks similar to 2.4.30 in fib_get_procinfo(), fib_magic() and
other functions involved. I believe its simply a change of how userspace
sets up the routes:

# route -n

172.16.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
0.0.0.0         172.16.0.1      0.0.0.0         UG    0      0        0 eth0

# route add -net 127.0.0.0/8 lo
# route -n

172.16.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0
127.0.0.0       0.0.0.0         255.0.0.0       U     0      0        0 lo
0.0.0.0         172.16.0.1      0.0.0.0         UG    0      0        0 eth0

"route" seems to add all routes to the main table. My debian system
relies on the kernel setting up loopback correctly, so it doesn't add
a route itself.

Regards
Patrick
