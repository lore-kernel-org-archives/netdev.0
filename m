From: Roland Dreier <roland@topspin.com>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Tue, 21 Sep 2004 08:23:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <523c1br6ho.fsf@topspin.com>
References: <52fz5esxx6.fsf@topspin.com>
	<20040919140133.60ea3fb3.davem@davemloft.net>
	<1095628759.1049.22.camel@jzny.localdomain>
	<52y8j5r1d6.fsf@topspin.com>
	<1095766554.1049.49.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095766554.1049.49.camel@jzny.localdomain> (jamal's message of
 "21 Sep 2004 07:35:54 -0400")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    jamal> Are you doing the path manager from user space or kernel?
    jamal> Its easy to generate netlink events to user space; you
    jamal> could then have the manager create path from user space.

The subnet manager (== big application that assigns paths to everyone
on a fabric, etc) will be in user space running on a single node.  But
I would prefer to have the IPoIB driver be contained within the kernel
to avoid complications like needing to start a userspace helper from
an initrd for NFS root, etc.  Sending path queries to the subnet
manager is pretty simple so I don't think there's an issue with having
that piece of code in the kernel.

Also, if the path record lookup is done in userspace, it seems the
driver will be passed 20-byte hardware addresses and need to look up
the path in some shadow ARP table for every packet, which doesn't seem
very efficient.

I'd like to understand David's approach better, since it seems he
knows how to avoid that.  Unfortunately I don't understand the
hard_header_cache() etc. methods well enough for his original
explanation to make sense to me.  Hopefully he'll have time to explain
in a little more detail...

Thanks,
  Roland
