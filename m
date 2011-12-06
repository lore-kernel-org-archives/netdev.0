From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bridge: HSR support
Date: Tue, 6 Dec 2011 15:27:45 -0800
Message-ID: <20111206152745.7dd6bc1c@nehalam.linuxnetplumber.net>
References: <4E948A04.8060400@enea.com>
	<20111011112821.28cd3e51@nehalam.linuxnetplumber.net>
	<4E94D67A.9060207@enea.com>
	<4EA5738B.8080008@enea.com>
	<4EAACB7A.4090207@enea.com>
	<20111028175421.339b7c49@s6510.linuxnetplumber.net>
	<4EDEA3E9.3070004@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Arvid Brodin <arvid.brodin@enea.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36049 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754608Ab1LFX1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 18:27:48 -0500
In-Reply-To: <4EDEA3E9.3070004@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Dec 2011 00:23:21 +0100
Arvid Brodin <arvid.brodin@enea.com> wrote:

> Stephen Hemminger wrote:
> > On Fri, 28 Oct 2011 17:34:18 +0200
> > Arvid Brodin <arvid.brodin@enea.com> wrote:
> > 
> >> Ok, so after a lot of reading and looking through code I have this idea of a
> >> standalone solution:
> >>
> >> 1) Add ioctls to create (and remove) "hsr" netdevs which encapsulates two
> >>    physical Ethernet interfaces each (somewhat like the bridge code does, but
> >>    with precisely 2 interfaces slaved).
> > 
> > Please use the newer netlink interface and the master attribute for this
> > rather than inventing yet another ioctl.
> 
> 
> Is the rtnl interface documented anywhere (the usage of the different IFLA_
> flags etc.)? Specifically: how do I use the IFLA_MASTER flag (what's the
> meaning of the 32-bit data it wants, and how is it used by the kernel)? I 
> haven't been very successful figuring this out by looking at the kernel code.


Look at bridging or bonding. the u32 is the ifindex of the master device (ie
where packets are being forwarded to).

> 
> Also, how do I best tell the kernel which my slave devices are when creating
> the hsr device? Should I create my own IFLA_HSR_UNSPEC, etc, or can I use some
> of the generic flags?

Look at macvlan, vlan, or bridging. There this is done by processing a newlink
message.


> Oh, and the kernel (struct rtnl_link_ops).newlink method has two (struct
> nlattr *[]) params: tb and data. What are their roles?
> 
> 
