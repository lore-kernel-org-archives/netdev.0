From: Felix von Leitner <felix-linuxkernel@fefe.de>
Subject: Re: IPv6 has trouble assigning an interface
Date: Tue, 26 Apr 2005 08:10:11 +0200
Message-ID: <20050426061011.GA8527@codeblau.de>
References: <20050311202122.GA13205@fefe.de> <20050311173308.7a076e8f.akpm@osdl.org> <20050324.205902.119922975.yoshfuji@linux-ipv6.org> <20050425195736.GB3123@codeblau.de> <Pine.LNX.4.61.0504252359580.4921@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261330AbVDZGKT@vger.kernel.org>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0504252359580.4921@netcore.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thus spake Pekka Savola (pekkas@netcore.fi):
> >Here is an strace of some piece of code of mine:
> >
> >socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 3
> >setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [12884901889], 4) = 0
> >bind(3, {sa_family=AF_INET6, sin6_port=htons(8002), inet_pton(AF_INET6, 
> >"::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
> >setsockopt(3, SOL_IPV6, IPV6_MULTICAST_LOOP, "\1", 1) = 0
> >[...]
> >sendto(3, "ncp-lowfat-1.2.2", 16, 0, {sa_family=AF_INET6, 
> >sin6_port=htons(8002), inet_pton(AF_INET6, "ff02::6e63:7030", &sin6_addr), 
> >sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EADDRNOTAVAIL (Cannot assign 
> >requested address)
> >
> >ff02 is a link-local multicast address.  I've bound to ::.  How can this
> >fail?  link-local should always work, even if no routes are set and no
> >router has been found.
> Umm.. link-local unicast and multicast both require that you specify 
> the interface, because otherwise it's ambiguous -- how could the 
> kernel know which interface should be used to send the packet?

OK for unicast.
But multicast?  I expected link-local multicast to send on _all_
interfaces if I don't specify one.

Felix
