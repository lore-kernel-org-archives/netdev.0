From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bug#625914: linux-image-2.6.38-2-amd64: bridging is not
 interacting well with multicast in 2.6.38-4
Date: Mon, 9 May 2011 20:15:28 -0700
Message-ID: <20110509201528.52d87ec4@nehalam>
References: <20110506201234.6297.70279.reportbug@ip6-localhost>
	<1304995124.4065.157.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Noah Meyerhans <noahm@debian.org>, 625914@bugs.debian.org,
	netdev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58508 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243Ab1EJDPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2011 23:15:30 -0400
In-Reply-To: <1304995124.4065.157.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2011 03:38:44 +0100
Ben Hutchings <ben@decadent.org.uk> wrote:

> On Fri, 2011-05-06 at 13:12 -0700, Noah Meyerhans wrote:
> > Package: linux-2.6
> > Version: 2.6.38-3
> > Severity: normal
> > 
> > Hi. I've got a system that hosts several kvm virtual hosts.  The VMs
> > access the network via tap devices bridged with a physical interface.
> > After upgrading to linux-image-2.6.38-2-amd64_2.6.38-4, I noticed that
> > the virtualhosts were not autoconfiguring their IPv6 interfaces.
> > Debugging revealed that no multicast was passing over the bridge.
> > 
> > The bridge configuration is:
> > bridge name     bridge id               STP enabled     interfaces
> > br0             8000.0002e3080eb5       no              eth1
> >                                                         tap0
> >                                                         tap1
> >                                                         tap2
> > 
> > If I attach tcpdump to br0, I can see multicast (e.g. IPv6 Neighbor
> > Solicitation) packets.  However, if I attach tcpdump to eth1, I do not
> > see multicast packets sourced from one of the VMs.
> > 
> > Downgrading to 2.6.38-3 solves the problem.
> 
> This is pretty weird.  Debian version 2.6.38-3 has a few bridging
> changes from stable 2.6.38.3 and 2.6.38.4, but they don't look like they
> would cause this.
> 
> Ben.

There are two possible explainations:
  1. In 2.6.37 and kernels the bridge uses IGMP snooping, there were several
     fixes to that in the stable kernel; especially related to IPv6.

  2. There was also a recent change to block link local multicast
     address. But that should impact what you are doing.
