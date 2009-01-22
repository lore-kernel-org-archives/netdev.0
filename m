From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Thu, 22 Jan 2009 20:12:39 +0100
Message-ID: <20090122191239.GA16347@uranus.ravnborg.org>
References: <49786A59.6040706@walrond.org> <20090122175645.GA14178@uranus.ravnborg.org> <4978C301.1040705@walrond.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Walrond <andrew@walrond.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepb.post.tele.dk ([195.41.46.236]:50656 "EHLO
	pfepb.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755542AbZAVTK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 14:10:57 -0500
Content-Disposition: inline
In-Reply-To: <4978C301.1040705@walrond.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[restored lkml]

On Thu, Jan 22, 2009 at 07:03:29PM +0000, Andrew Walrond wrote:
> Sam Ravnborg wrote:
> >
> >I checked the include guards and they are correct.
> >
> >Could you please investige where it picks up the first definition
> >of struct iphdr.
> >
> >  
> Here you go:
> 
> $ make iptunnel.o
> 
> cc -D_GNU_SOURCE -O2 -Wall -g  -I. -idirafter ./include/ -Ilib   -c -o 
> iptunnel.o iptunnel.c
> In file included from /usr/include/linux/if_tunnel.h:5,
>                 from iptunnel.c:39:
> /usr/include/linux/ip.h:85: error: redefinition of 'struct iphdr'
> 
> $ grep -r iphdr /usr/include/
> 
> /usr/include/netinet/ip.h:struct iphdr
> /usr/include/netinet/tcp.h: * This should be defined as MIN(512, IP_MSS 
> - sizeof (struct tcpiphdr)).
> /usr/include/linux/if_tunnel.h:    struct iphdr        iph;
> /usr/include/linux/ip.h:struct iphdr {
> 
> $ grep netinet/ip.h iptunnel.c
> 
> #include <netinet/ip.h>
> 
> So linux/ip.h is clashing with glibc(2.8)'s netinet/ip.h

I took a look at my netinet/ip.h and this is obviously
the same structure.
But I do not know what the right answer is here.

Added netdev..

This may be a general thing. Because iphdr is
no a kernel thing, it is an IP thing. So one could argue
that the kernel should not export it in the first place.

	Sam
