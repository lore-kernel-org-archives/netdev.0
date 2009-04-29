From: Mark Smith
	<lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
Subject: Re: [RFC, PATCH 2.6.29.2] Ethernet V2.0 Configuration Testing
 Protocol, revision 20090428
Date: Thu, 30 Apr 2009 06:59:50 +0930
Message-ID: <20090430065950.529359e3.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
References: <20090428220143.31395c24.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
	<20090428161545.0612476d@nehalam>
	<20090429210436.a515465b.lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org>
	<20090429115716.3e315812@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.adam.net.au ([202.136.110.253]:54707 "EHLO
	smtp1.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756352AbZD2V3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 17:29:54 -0400
In-Reply-To: <20090429115716.3e315812@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Wed, 29 Apr 2009 11:57:16 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Wed, 29 Apr 2009 21:04:36 +0930
> Mark Smith <lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org> wrote:
> 
> > Hi Stephen,
> > 
> > Thanks for you time.
> > 
> > On Tue, 28 Apr 2009 16:15:45 -0700
> > Stephen Hemminger <shemminger@vyatta.com> wrote:
> > 
> > > On Tue, 28 Apr 2009 22:01:43 +0930
> > > Mark Smith  <lnx-netdev@95022607b6285f9c5d5ea31ea9d8a7ac.nosense.org> wrote:
> > > 
> > > > Hi,
> > > > 
> > > > Following on from my initial ECTP post on the 23rd of April, here is an
> > > > updated revision.
> > > > 
> > > > Changes:
> > > > 
> > <snip>
> > 
> > > > 
> > > > Feedback from some networking and sys admin people I've told about it
> > > > has been positive - they all agree with the benefit of being able to
> > > > perform "ping" style testing on an Ethernet segment without requiring
> > > > IP to be configured.
> > > > 
> > > > Any suggestions for improvement would be most appreciated.
> > > > 
> > > > Thanks very much,
> > > > Mark.
> > > > 
> > > 
> > > Why does this have to be in the kernel?  Why not all in user space
> > > with AF_PACKET?
> > 
> > It doesn't have to be, however I think the same question could be asked
> > as to why the IPv4, IPv6 and 802.2/LLC echo reply functions are in the
> > kernel, when they could be implemented in user space too.
> > 
> > Here are the reasons why I think it should be in the kernel:
> > 
> > o  As the Ethernet V2.0 protocol is implemented in the kernel, the
> > offical Ethernet V2.0 testing function should also be implemented in
> > the kernel. Making Ethernet layer testing rely on a user space
> > process makes it less reliable and less universally available as a
> > specific test of Ethernet link layer connectivity. IIRC, this is the
> > justification for why IPv4 and IPv6 ICMP echo reply functions are in
> > operating system kernels rather than as user space processes. 
> 
> RSTP is implemented in user-space (IEEE 802.1d) and other standard
> protocols as well. This reason is invald.
> 

RSTP is not a basic connectivity testing protocol. It's far more than a
just an Ethernet functional equivalent to 'ping'.

Why do you think protocols that could have been implemented in user
space haven't been? The only justification I'm aware of is the pretty
much the universal availability one. For a lot of protocols e.g. RSTP, 
universal availablility isn't of value, because they're not useful to
everybody. However, basic connectivity testing protocols are, certainly
for people like me for whom troubleshooting network connectivity faults
is a daily or weekly occurance. I've had system admins say it'd be
useful for them to.

So should I submit patches that rip every protocol out of the kernel
that could be implemented in user space using AF_PACKET? That'd be all
of them I think, excepting the AF_PACKET code itself. In the least,
would you support patches to remove IPv4 and IPv6 ICMP Request
processing and 802.2/LLC TEST processing from the kernel, if I submit
them?

While I've made this protocol optional for the kernel, compliance with
the Ethernet V2.0 spec, which states:

"All Ethernet stations must support the configuration testing
functions."

mean that this protocol should be available any time Ethernet V2.0 is,
and the only way to be assured of that is to put it in the kernel. It
could be argued that any time Ethernet is enabled in the kernel, then
this protocol must be too.

> > o  Compared to near equivalent link tesing using IPv4 ping, ECTP doesn't
> > require any pre-configuration at all.
> 
> Doing it in userspace would not require configuration either and could
> be more flexible. It would work better with existing infrastructure
> firewalling, rate limiting, ...
> 
> > o  I think it can serve as a "hello world"-like example of basic packet
> > processing in the kernel. Other protocols that exist in the kernel that
> > can be used as examples are pretty complicated when compared to ECTP.
> > To understand their implementations, you need to understand the protocol
> > well before hand, which can be a fairly time consuming task. As ECTP is
> > a very simple, single packet format protocol, that has pretty simple
> > processing, the time investment in understanding it is fairly small -
> > probably well and truly less than an hour. I think that, combined with
> > what I hope is a very straight forward and easy to follow
> > implementation, could help people come quickly up to speed with the
> > basics of kernel packet processing. It's for this reason that I also 
> > invested quite a bit of time in providing an overview of the protocol
> > in the Documentation/networking/ectp.txt file. I think it also could be
> > a simple to follow example of how to use SKB queues, and how to use the
> > new high res timers subsystem.
> 
> Example code, doesn't necessarily have to be shipped code.
> 

True, but there's precedent, and the nice thing is that if you've got
the official kernel source, you've got the examples:

drivers/net/pci-skeleton.c
drivers/net/isa-skeleton.c

My code is not only a fairly basic example, it's does something quite
useful to a lot of people, unlike those files, which are purely example
code. I think that justifies it being "carried around" in the official
kernel source.

> > o  It would be another method for testing network stack latency. The
> > recent udpping testing that is being performed by Christoph Lameter is
> > testing the Ethernet, IP and UDP layers of the kernel. Using ECTP for
> > this type of testing isolates the IP and UDP implementations from
> > influencing the results.
> 
> This reason does make sense, but the latency of ethernet driver
> is probably greater than userspace overhead
> 

I wouldn't dispute this.

>  
> > o  It provides more link layer testing capabilities than the 802.2/LLC
> > TEST function. ECTP supports querying of available ECTP nodes via
> > broadcast and multicast requests, and testing of paths between
> > a number of stations. The 802.2/LLC TEST function only supports
> > request / reply testing between a pair of stations.
> 
> 
> But can it be firewalled?

Actually, that raises a limitation with ebtables that I'd like to be
overcome. As I understand it, ebtables can only be applied to bridged
traffic, meaning that if you just want "plain" firewalling on an
interface, you've got to create a bridge and then add the interface to
the bridge. I'd like the ability to filter at layer 2 without the
complication of having to create a "one-armed bridge."

Because of that limitation with ebtables, I added to sysctls to ECTP,
to effectively allow you to firewall it:

net.ectp.bmc_ignore - to ignore broadcast and multicast ECTP packets

net.ectp.uc_ignore - to ignore unicast ECTP packets

Regards,
Mark.
