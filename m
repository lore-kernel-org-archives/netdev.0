From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 14:22:11 -0800
Message-ID: <424C7813.4000101@candelatech.com>
References: <424C6089.1080507@candelatech.com>	 <1112303627.1073.71.camel@jzny.localdomain>	 <424C6B10.6030200@candelatech.com> <1112306031.1073.109.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1112306031.1073.109.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2005-03-31 at 16:26, Ben Greear wrote:

> You can configure actions using sockets (netlink sockets).
> Thats what tc does for example. As a matter of fact you already have a
> "language" - its what tc is, sample BNF grammar of the language:
> 
> ---
> [root@jzny root]# tc
> Usage: tc [ OPTIONS ] OBJECT { COMMAND | help }
> where  OBJECT := { qdisc | class | filter }
>        OPTIONS := { -s[tatistics] | -d[etails] | -r[aw] | -b[atch] file
> }

My personal opinion is that netlink sockets are a pain in the ass to deal
with, and there is no way I want to try to programatically parse the tc
input or output.

And probably not so easy to manipulate from a kernel module.

And BNF cannot be more powerful than a c/c++ program with a byte-buffer
representing the entire ethernet frame.

>>I can also create a nice little set of virtual interfaces
>>and connections  rdd0 <-> rdd1  |bridge|  rdd2 <-> rdd3.  I can then send traffic
>>from rdd0 to rdd3 across the bridge, etc.  Now, this last bit is fairly
>>contrived, but it happens to help me with some testing on my laptop which
>>lacks a lot of external ethernet interfaces :)
> 
> So your goal is to define a path that the packet takes inside the kernel
> across multiple devices? i.e some form of loose source routing?

Well, I have already hacked the kernel to allow sending traffic from eth0 to
eth3 across a loopback cable.  In my example above, you can think of
rdd0 - rdd3 as eth0 - eth3:  eth0 has an IP 10.1.1.2, connected to
eth1 with a loopback cable.  eth1 has NO ip and is bridged to eth2 in
software.  eth2 has NO ip and is connected via loopback cable to eth3.
eth3 has an IP 10.1.1.3.  As far as the networking protocol stacks are
concerned, eth0 is connected via loopback cable to eth3.

My primary goal is to enable this bridge to not require so many physical
ethernet ports.  This 'bridge' is actually my network emulator that I sell
for a living, so if I can cram twice as much functionality into the same number of
physical interfaces, I stand to gain.  Since I remove the IP addresses from the bridged interfaces,
I can do the bridging without hacking another hook into the dev.c pkt receive
routines, and since my redirect devices are net_devices sending & receiving
ethernet packets, they just work with my existing code, ethereal, and every
other tool I've tried.  Heck, I could probably run 802.1Q VLANs across them
as well if I wanted :)

>>To be honest, I didn't dig into the actions.  It would be much harder for
>>me to manage things in that manner, whereas virtual interfaces just work
>>for me.
> 
> 
> Understood - just not empathized ;->

Fair enough :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
