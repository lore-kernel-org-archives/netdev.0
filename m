From: Felix von Leitner <felix-kernel@fefe.de>
Subject: Re: socket api problem: can't bind an ipv6 socket to ::ffff:0.0.0.0
Date: Tue, 17 Mar 2009 01:18:09 +0100
Message-ID: <20090317001809.GG32111@codeblau.de>
References: <20090316233934.GD32111@codeblau.de> <20090316170040.4fa6cff7@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ioctl.codeblau.de ([80.190.240.67]:55285 "EHLO codeblau.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752973AbZCQASN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2009 20:18:13 -0400
Content-Disposition: inline
In-Reply-To: <20090316170040.4fa6cff7@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Here's an strace:
> > 
> > socket(PF_INET6, SOCK_STREAM, IPPROTO_IP) = 3
> > fcntl(3, F_GETFL)                       = 0x2 (flags O_RDWR)
> > fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
> > setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> > bind(3, {sa_family=AF_INET6, sin6_port=htons(6969), inet_pton(AF_INET6, "::ffff:0.0.0.0", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EADDRNOTAVAIL (Cannot assign requested address)
> > 
> > This is supposed to work, and it works on other operating systems, even
> > on Mac OS X.
> > 
> > I think it used to work on Linux, too.
> > 
> > I'm using 2.6.29-rc7 right now, but others have reported this not
> > working on distro kernels, too.
> > 
> > Felix
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html

> Most likely you already have same port open on IPV4 and unless
> you set IPV6 only, the bind bind will fail. The standard way
> of doing servers is to bind only for IPV6 and handle IPV4
> clients via the 6-4 address mapping.

No I don't have anything else on that port.

BTW, just for the record, binding to ::ffff:10.0.0.3 (my eth0 address at
the moment) still works, so the mechanism is not completely broken.

Felix
