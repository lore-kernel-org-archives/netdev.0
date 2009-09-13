From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [net-next PATCH] etherdevice.h: random_ether_addr update
Date: Sun, 13 Sep 2009 13:17:52 +0930
Message-ID: <20090913131752.462abc01@opy.nosense.org>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	<20090910190703.25d14533@nehalam>
	<1252638163.4355.35.camel@Joe-Laptop.home>
	<20090911.121542.45333246.davem@davemloft.net>
	<1252700442.15292.62.camel@Joe-Laptop.home>
	<20090911141554.0072d365@nehalam>
	<1252717067.29420.22.camel@Joe-Laptop.home>
	<20090913094409.2dd88212@opy.nosense.org>
	<20090913100342.4f6a2417@opy.nosense.org>
	<1252802686.4400.19.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	donald.c.skidmore@intel.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.adam.net.au ([202.136.110.249]:55647 "EHLO
	smtp3.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754993AbZIMDsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2009 23:48:03 -0400
In-Reply-To: <1252802686.4400.19.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Sep 2009 17:44:46 -0700
Joe Perches <joe@perches.com> wrote:

> On Sun, 2009-09-13 at 10:03 +0930, Mark Smith wrote:
> > Hmm, probably didn't make my point all that clear. IOW, anything that
> > can contribute to avoiding duplicate mac addresses is worth it in my
> > opinion, when compared to the time (usually hours) involved in
> > troubleshooting duplicate mac addresses.
> 
> Avoiding an initial octet of "02", which is partially
> assigned to 3Com and others, might be useful.
> 

I wouldn't necessarily disagree. I would say that if that path was
taken, then you'd probably also want to be avoiding all the other
well known mac addresses that do or can fall within the locally
assigned range e.g. DECnet 0xAA addresses, Microsoft's  use of
02:01:00:00:00:00 and similar addresses for their Network Load
Balancing software, the unicast version of the CF:00:00:00:00:00
multicast address use for ECTP, the unicast version of the
33:33:xx:xx:xx:xx IPv6 ND multicast ranges etc.

Having thought about this issue a bit before, another thought might be
to have somebody get the Linux kernel it's own OUI, and then have
addresses randomly selected out of that. As my day job is networking,
I'd find some value in being able to see a well known OUI for Linux
randomly generated addresses, rather than the complete randomness that
is the case now.

The drawback there is that there are then only 24 bits octets of
randomness in the addresses that each host can independently choose to
use, which isn't anywhere near the as random as the 2^46 the LA address
space provides. For most ethernet segments, 24 bits of randomness might
be ok, however some of the very large metro ethernet networks are
starting to carry 16000+ MAC addresses, all within the same, very
controlled broadcast domain.


> Not drawing from entropy I think useful, but it's debatable.
> 
> 

I'm guessing there are other things in the kernel that would be taking
away far more entropy, far more often. IIRC, TCP connection initial
sequence number selection would be one example.
