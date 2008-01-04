From: Milan Kocian <milon@wq.cz>
Subject: Re: network interface state
Date: Fri, 04 Jan 2008 21:58:26 +0100
Message-ID: <1199480306.21869.39.camel@sm.wq.cz>
References: <473B61C8.3030302@redhat.com>
	 <20071114.153103.230463871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, drepper <drepper@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wq.cz ([82.202.95.52]:56833 "EHLO rd.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753297AbYADVxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 16:53:25 -0500
In-Reply-To: <20071114.153103.230463871.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2007-11-14 at 15:31 -0800, David Miller wrote:
> From: Ulrich Drepper <drepper@redhat.com>
> Date: Wed, 14 Nov 2007 12:59:52 -0800
> 
> > Just FYI, with the current getaddrinfo code it is even more critical to
> > get to a point where I can cache network interface information and query
> > the kernel whether it changed.  We now have to read the RTM_GETADDR
> > tables for every lookup.  It was more limited with the old, incomplete
> > implementation.
> > 
> > Even if it's something as simple as a RTM_SEQUENCE request which returns
> > a number that is bumped at every interface change.
> 
> This sounds like a useful feature.  Essentially you want a generation
> ID that increments every time a configuration change is made?
> 
> Most daemons handle this by listening for events on the netlink
> socket, but I understand how that might not be practical for
> glibc.
> 
> > Related: I need to know about the device type (the ARPHRD_* values) to
> > determine whether a device is for a native transport or a tunnel.  What
> > I currently do is:
> > 
> > - - at the beginning I get information about all interfaces using
> > RTM_GETADDR
> > 
> > - - them later I have to find the device type by
> > 
> >   + reading the RTM_GETLINK data to get to the device name
> > 
> >   + then using the name and ioctl(SIOCGIFHWADDR) I get the device type
> > 
> > 
> > It would be so much nicer if the device type would be part of the
> > RTM_GETADDR data, or at least the RTM_GETLINK data.
> 
> It's part of the link information, Look in ifinfomsg->ifi_type
> 
> In general be suspicious if it seems netlink isn't providing
> the same information available via the old ioctls :-)

Sorry for late little offtopic question: Exists any simple way how to
differentiate virtual network devices from real devices (e.g. vlans,
bridges)?

They have the same ifinfomsg->ifi_type as real devices (ARPHRD_ETHER). I
know to differentiate vlans via IFLA_LINK attribute. But how to
differentiate bridges from real devices I didn't determine.
Thanks for any answer.

regards,

milan kocian



