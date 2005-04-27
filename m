From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: IPv6 has trouble assigning an interface
Date: Wed, 27 Apr 2005 16:31:18 -0700
Message-ID: <OF383E111F.F9F6791E-ON88256FF0.007F9539-88256FF0.00813651@us.ibm.com>
References: <d3c101b00bd9573e30aa843e2335439e@mac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Felix von Leitner <felix-linuxkernel@fefe.de>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Pekka Savola <pekkas@netcore.fi>,
        "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <d3c101b00bd9573e30aa843e2335439e@mac.com>
To: Kyle Moffett <mrmacman_g4@mac.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

netdev-bounce@oss.sgi.com wrote on 04/27/2005 03:57:05 PM:

> On Apr 26, 2005, at 02:10, Felix von Leitner wrote:
> > OK for unicast. But multicast?  I expected link-local multicast
> > to send on _all_ interfaces if I don't specify one.

(I didn't see the article this is quoting-- apparently wasn't CC-ed
to "netdev" as the original was).
        Multicasting doesn't work that way. Multicast group memberships
are per-device (whether or not they are link-local). If you join
the same group address on two different devices, they'll only be the
same group if there are multicast routers on the two links connecting
them in the same multicast routing hierarchy. With a scope broader
than link-local, and a multicast router on that link, the packets
can be forwarded to other links, but they won't be forwarded to
every host on the internet in that group (!), and there are sometimes
good reasons for having different partitions of the same group
within a single organization. So, the same group number on two
different links is not necessarily the same group. It depends
entirely on whether the two groups have common multicast routers
with no policy restricting forwarding for that group between them.
        This is how IPv4 multicasting works, too. You join a group
on a particular device.

                                                                +-DLS
