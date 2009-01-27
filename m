From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Mon, 26 Jan 2009 21:08:35 -0800 (PST)
Message-ID: <20090126.210835.181389836.davem@davemloft.net>
References: <20090122175645.GA14178@uranus.ravnborg.org>
	<4978C301.1040705@walrond.org>
	<20090122191239.GA16347@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@walrond.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sam@ravnborg.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48769
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751170AbZA0FIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:08:38 -0500
In-Reply-To: <20090122191239.GA16347@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 22 Jan 2009 20:12:39 +0100

> On Thu, Jan 22, 2009 at 07:03:29PM +0000, Andrew Walrond wrote:
> > $ grep -r iphdr /usr/include/
> > 
> > /usr/include/netinet/ip.h:struct iphdr
> > /usr/include/netinet/tcp.h: * This should be defined as MIN(512, IP_MSS 
> > - sizeof (struct tcpiphdr)).
> > /usr/include/linux/if_tunnel.h:    struct iphdr        iph;
> > /usr/include/linux/ip.h:struct iphdr {
> > 
> > $ grep netinet/ip.h iptunnel.c
> > 
> > #include <netinet/ip.h>
> > 
> > So linux/ip.h is clashing with glibc(2.8)'s netinet/ip.h
> 
> I took a look at my netinet/ip.h and this is obviously
> the same structure.
> But I do not know what the right answer is here.
> 
> Added netdev..
> 
> This may be a general thing. Because iphdr is
> no a kernel thing, it is an IP thing. So one could argue
> that the kernel should not export it in the first place.

The fly in the ointment is linux/if_tunnel.h

We export a structure there for a userland interface which
uses "struct iphdr".

Because of that, we are faced with the difficult choice between
defining the structure (as we do) in linux/ip.h or using some ugly
__KERNEL__ ifdefs in linux/if_tunnel.h to conditionally include
netinet/ip.h instead. :-/

Really, I have no idea what to do about this as the problem has
existed for so long.
