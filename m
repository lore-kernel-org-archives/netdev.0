From: jamal <hadi@cyberus.ca>
Subject: Re: RFC:  Redirect-Device
Date: 31 Mar 2005 16:13:47 -0500
Message-ID: <1112303627.1073.71.camel@jzny.localdomain>
References: <424C6089.1080507@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C6089.1080507@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 15:41, Ben Greear wrote:
> I created a new virtual ethernet device that solves a problem
> I faced.  I thought I'd see if anyone else sees a use for this,
> and if so, I'll work to polish the patch so that it can be
> accepted into the kernel.
> 
> The redirect device is fairly simple:
> 
> You create a pair of them, each associated with each other.
> When you transmit on one, the other one receives a packet.
> The devices are presented as regular ethernet devices, and they
> have MACs, will do ARP, and other such things.
> 
> I use these in the following manner:
> 
> I have a software bridge that works by registering a protocol for all
> packets on, for example, eth1, and it will forward these packets to another
> device.  In my case, the other device will be one of the re-direct interfaces
> (rdd0).  Both eth1 and rdd0 will NOT have any IP configuration.  This keeps
> the stacks from interfering with my bridge.  rdd1 will have the IP address that
> would normally be associated with eth1.
> 
> This allows me to have total control of the packets flowing between the physical
> ethernet interface and the ethernet and higher level protocols on the rdd1 interface.
> I believe this is the only way to have such total control of packets, for both inspection
> and arbitrary modification, before the packets hit the protocol handlers.
> 

I must be missing something: What is it that this device can do that the
mirred action cant do? 
Or in general the action framework on the ingress side?
We can redirect to any arbitrary device; we can mirror to any arbitray
device; we can drop, mangle packets identified via classification rules
in any arbitrary way etc


cheers,
jamal
