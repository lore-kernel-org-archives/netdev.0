From: Ben Greear <greearb@candelatech.com>
Subject: Re: send-to-self (was Re: routing bug report for 2.4)
Date: Mon, 30 Jun 2003 00:59:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EFFEDD7.5020205@candelatech.com>
References: <Pine.LNX.4.44.0306292307130.9328-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0306292307130.9328-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Julian Anastasov wrote:
> 	Hello,
> 
> 	Ben, I have something for comments and testing (compiled
> only):
> 
> http://www.ssi.bg/~ja/send-to-self-2.4.21-1.diff

Just moved to my new home..will be a few days before I can
take a detailed look at this..and your long description
confused my tired mind for tonight...  I'll look in
detail soon.

> 
> The usage should be:
> eth0/loop=1
> eth1/loop=1
> bind to src IP from eth0 and connect to local IP on eth1
> 
> Be ready, there can be something totally wrong.
> 
> I'm avoiding the arp_filter changes. The setup uses
> asymmetric routing so better use arp_filter=0 or other

arp_filter=1, right?

> ARP filtering tools that can restrict our ARP replies 
> only via the desired device.

I want to avoid strange(r) routing configurations, as I'm already
using lots of routing tricks, and don't want to confuse matters
more.  I also turn on arp filtering to ensure the arps go out the
right interface currently.

You should be able to easily test most of the changes your code
if you have a machine with two ethernet interfaces and a loopback
cable...

My requirements are:

1)  Both ethernet ports communicate over the exernal link, UDP & IP traffic.
     Third-party programs if possible, thus I set the flag on the interface in
     my patch, not on an individual socket, though I do have to BINDTODEVICE and
     policy-base base route to get things working right...
1b)  Allow both same-subnet comm (eth1 & eth2 are on same subnet), and also
      routed traffic (eth1 & eth2 have their own default router, similar to the
      previously discussed routing setup)

2)  Allow normal non-looped communication on the ports, including policy-based routing
     based on source addr.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
