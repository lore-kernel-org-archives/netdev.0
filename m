From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: ping6 error
Date: Wed, 21 Apr 2004 15:05:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFBD219784.C2049213-ON88256E7D.0078B0F7-88256E7D.00796149@us.ibm.com>
References: <20040421150832.1f1dcde9%hibi665@oki.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040421150832.1f1dcde9%hibi665@oki.com>
To: Takashi Hibi <hibi665@oki.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Takashi Hibi wrote on 04/20/2004 11:08:32 PM:

> There are IPv6 addresses for which ping6 doesn't work.
> The host has a global IPv6 address.

> $ ping6 ff05::1    (site-local multicast address)
> connect: Cannot assign requested address

This makes less sense (but doesn't fail for me on 2.6.x kernels).
Multicast memberships are per-interface, so a multi-homed host or
router may not have a route for that address to the interface you
actually wanted. It's almost always best to specify "-I" in ping6
to get what you want.

> $ ping6 fec0::1    (site-local address)
> connect: Cannot assign requested address

This works fine on my 2.6.1 system talking to my 2.6.5 system,
when I have an address with an fec0 prefix on both. If you don't,
it's probably a routing table issue-- try "netstat -A inet6 -rn"
and see if you have routing table entries on each so that they
can talk to each other.

                                                +-DLS
