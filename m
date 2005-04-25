From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPv6 has trouble assigning an interface
Date: Mon, 25 Apr 2005 15:38:15 -0700
Message-ID: <OF11B6C702.AF232267-ON88256FEE.007B2DE9-88256FEE.007C5A46@us.ibm.com>
References: <20050425195736.GB3123@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com,
        "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050425195736.GB3123@codeblau.de>
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It's failing because it doesn't know what interface you want to send on, 
and link-local
addresses don't narrow that down any. If you bind to a specific IPv6 
address, it'll use
that interface (as a work-around). Adding a route for the multicast 
address may also
work (haven't tried). I'd expect using IPV6_MULTICAST_IF would work, but a 
quick
test appears that it doesn't. Specifying a sin6_scope_id as the interface 
index on the
sendto() is another way of specifying the device that doesn't appear to 
work.

So, there may be a bug. Note that if you bind to "::" without doing 
anything else and
send to a link-local address, it can't know what interface you want to 
send on by
the destination, so your program won't control which interface it'll send 
on. Doing
that by binding to a specific interface's IPv6 address works for me (the 
failure is
in assigning the source address when it isn't known). Specifying the 
device in
other ways ought to work, too, so I'll look into this a bit more (as will 
others, no doubt).

                                                        +-DLS

> ff02 is a link-local multicast address.  I've bound to ::.  How can this
> fail?  link-local should always work, even if no routes are set and no
> router has been found.

> Felix
