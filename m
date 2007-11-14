From: David Miller <davem@davemloft.net>
Subject: Re: network interface state
Date: Wed, 14 Nov 2007 15:31:03 -0800 (PST)
Message-ID: <20071114.153103.230463871.davem@davemloft.net>
References: <473B61C8.3030302@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754301AbXKNXbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 18:31:04 -0500
In-Reply-To: <473B61C8.3030302@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 14 Nov 2007 12:59:52 -0800

> Just FYI, with the current getaddrinfo code it is even more critical to
> get to a point where I can cache network interface information and query
> the kernel whether it changed.  We now have to read the RTM_GETADDR
> tables for every lookup.  It was more limited with the old, incomplete
> implementation.
> 
> Even if it's something as simple as a RTM_SEQUENCE request which returns
> a number that is bumped at every interface change.

This sounds like a useful feature.  Essentially you want a generation
ID that increments every time a configuration change is made?

Most daemons handle this by listening for events on the netlink
socket, but I understand how that might not be practical for
glibc.

> Related: I need to know about the device type (the ARPHRD_* values) to
> determine whether a device is for a native transport or a tunnel.  What
> I currently do is:
> 
> - - at the beginning I get information about all interfaces using
> RTM_GETADDR
> 
> - - them later I have to find the device type by
> 
>   + reading the RTM_GETLINK data to get to the device name
> 
>   + then using the name and ioctl(SIOCGIFHWADDR) I get the device type
> 
> 
> It would be so much nicer if the device type would be part of the
> RTM_GETADDR data, or at least the RTM_GETLINK data.

It's part of the link information, Look in ifinfomsg->ifi_type

In general be suspicious if it seems netlink isn't providing
the same information available via the old ioctls :-)
