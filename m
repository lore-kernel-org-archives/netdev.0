From: jamal <hadi@cyberus.ca>
Subject: Re: RFC:  Redirect-Device
Date: 31 Mar 2005 18:20:41 -0500
Message-ID: <1112311240.1096.13.camel@jzny.localdomain>
References: <424C6089.1080507@candelatech.com>
	 <1112303627.1073.71.camel@jzny.localdomain>
	 <424C6B10.6030200@candelatech.com>
	 <1112306031.1073.109.camel@jzny.localdomain>
	 <424C7813.4000101@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C7813.4000101@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 17:22, Ben Greear wrote:
> jamal wrote:
> > On Thu, 2005-03-31 at 16:26, Ben Greear wrote:

> 
> My personal opinion is that netlink sockets are a pain in the ass to deal
> with, and there is no way I want to try to programatically parse the tc
> input or output.
> 

Take a look at the libraries i mentioned. 

> And probably not so easy to manipulate from a kernel module.
> 
> And BNF cannot be more powerful than a c/c++ program with a byte-buffer
> representing the entire ethernet frame.
> 

For that level you write a program. In any language you want;->
I dont think you can beat the u32 classifier interface on how to
describe a packet. 

> >>I can also create a nice little set of virtual interfaces
> >>and connections  rdd0 <-> rdd1  |bridge|  rdd2 <-> rdd3.  I can then send traffic
> >>from rdd0 to rdd3 across the bridge, etc.  Now, this last bit is fairly
> >>contrived, but it happens to help me with some testing on my laptop which
> >>lacks a lot of external ethernet interfaces :)
> > 
> > So your goal is to define a path that the packet takes inside the kernel
> > across multiple devices? i.e some form of loose source routing?
> 
> Well, I have already hacked the kernel to allow sending traffic from eth0 to
> eth3 across a loopback cable.  In my example above, you can think of
> rdd0 - rdd3 as eth0 - eth3:  eth0 has an IP 10.1.1.2, connected to
> eth1 with a loopback cable.  eth1 has NO ip and is bridged to eth2 in
> software.  eth2 has NO ip and is connected via loopback cable to eth3.
> eth3 has an IP 10.1.1.3.  As far as the networking protocol stacks are
> concerned, eth0 is connected via loopback cable to eth3.
> 
>
> My primary goal is to enable this bridge to not require so many physical
> ethernet ports.  This 'bridge' is actually my network emulator that I sell
> for a living, so if I can cram twice as much functionality into the same number of
> physical interfaces, I stand to gain.  Since I remove the IP addresses from the bridged interfaces,
> I can do the bridging without hacking another hook into the dev.c pkt receive
> routines, and since my redirect devices are net_devices sending & receiving
> ethernet packets, they just work with my existing code, ethereal, and every
> other tool I've tried.  Heck, I could probably run 802.1Q VLANs across them
> as well if I wanted :)
> 

Like i said _all this_ is doable via actions. I dont know what your
bridge does but infact all the rest of the functionality exists.And your
bridge could be written as an action with very little code (and you get
the netlink interface for free. 
One thing you probably havent understood is that all the action stuff
that happens on ingress happens before dev.c pkt receive.

cheers,
jamal
