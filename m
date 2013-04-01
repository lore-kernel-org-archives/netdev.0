From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v1 3/4] vxlan: add ipv6 support
Date: Mon, 1 Apr 2013 16:03:38 -0400
Message-ID: <OFCC7D4E76.D0FD3154-ON85257B40.00659778-85257B40.006E30A9@us.ibm.com>
References: <OF5EB046E4.6295C3A5-ON85257B40.00537077-85257B40.00542577@us.ibm.com>	<20130401.130223.1527520446382659798.davem@davemloft.net>
	<OF1E30BC31.571FBD44-ON85257B40.005F5AF2-85257B40.0063627F@us.ibm.com> <20130401.141548.1477224368912481541.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:36395 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759695Ab3DAUEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 16:04:15 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 1 Apr 2013 14:04:14 -0600
In-Reply-To: <20130401.141548.1477224368912481541.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 04/01/2013 02:15:48 PM:
Date: Mon, 1 Apr 2013 14:05:37 -0400
> 
> >         I guess, but in this case, I'm not saying it's like a sockaddr 

> > with
> > device-specific requirements. Rather, I'm saying it's exactly a 
sockaddr--
> > it is either a sockaddr_in or a sockaddr_in6 and a family field to say
> > which.
> 
> in6_addr, which is what sockaddr_in6 is composed of, is precisely the
> problematic type that we want to avoid to elide the double definition
> error.
> 
> http://www.spinics.net/linux/fedora/libvir/msg70921.html
> 
> It's really not safe to use at the moment.
> 
> We're not creating more instances of this mess, and that decision
> is final.

Dave,

I think we're talking about two different things. I'm suggesting
we should use sockaddrs within the kernel module code as the type for
what is now a v4-only address but would be one of v4 or v6 after
adding v6 support.

Within the kernel module code, without changing any header files,
I'm suggesting we use the existing kernel sockaddr definitions and the
sa_family to know which address type we have, instead of defining
a new type local to vxlan.c with the same purpose and most of the
fields as a sockaddr for that very same kernel-only private data.

An additional comment is that those fields missing in the private type
and present in the sockaddr types are useful in cases that apply
to these destination addresses, too; "vxlan_ip" ought to have all the
fields a sockaddr_in6 or sockaddr_in does and if it did, then it
ought to use sockaddr/sockaddr_in/sockaddr_in6 for this kernel-only data.

My suggestion doesn't apply to anything at user level, or visible
to user level through an include file, kernel or glibc.

                                                        +-DLS
