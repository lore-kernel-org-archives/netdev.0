From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Bug 155] Outgoing MLD packets are not traversing netfilter
Date: Thu, 4 Dec 2003 09:58:27 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF7A4D0521.A45AB2B1-ON88256DF2.00613598@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Michael Bussmann <bus@mb-net.net>, netdev@oss.sgi.com,
        Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Harald,

>1) ip6_tables not matching it as icmp6 packet
>

Just a guess, but if netfilter6 doesn't go through all
the extension headers, then the protocol won't look like
ICMP6 because of the router alert option.


>2) ip6_queue copying the linklayer header to userspace
>
   >This means that skb->data does not point at the beginning of the
   >ipv6 packet (i.e. skb->data != skb->nh.ip6h), but to the beginning of
   >the hardware header (i.e. skb->data == skb->head).
   >
   >This is because mcast.c writes the full packet including the hardware
   >header and _then_ calls NF_HOOK.  All other code (ipv6 or ipv4) is
   >building the layer 3 packet, then calling NF_HOOK and later on (via
   >ipX_outpur_finish() or dst_output()) adding the hardware header.

...
>So the fundamental question (with regard to the ipv6 gods) is:  Is it
>really necessarry that the ipv6 mcast code bypasses the destination
>cache?

      It can't go through the routing table. The advertisements
are only meaningful on the particular interface, whether or not
there is a route pointing output multicasts to a different
interface (which is useful frequently, but MLD packets can't
go there too).

                              +-DLS
