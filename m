From: Richard Underwood <richard@aspectgroup.co.uk>
Subject: RE: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Wed, 20 Aug 2003 09:58:51 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <353568DCBAE06148B70767C1B1A93E625EAB61@post.pc.aspectgroup.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: skraw@ithnet.com, willy@w.ods.org,
	Richard Underwood <richard@aspectgroup.co.uk>,
	carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
	bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "'David S. Miller'" <davem@redhat.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> 
> Indeed, would people stop quoting from RFC 985 and
> RFC 826.

	In case anyone missed it, the following message was posted to
linux-net and netdev. This is currently a draft standard, but anyone
implementing IPv6 should be following it. It clearly states that the the
source address for the equivalent of the ARP request should be the INTERFACE
address.

	While it doesn't directly apply to IPv4 (except for David's claim
that IPv4 ARP is based on IPv6 ARP) it does clarify the situation nicely.

	I, for one, will be glad when (!) we all migrade to IPv6 and we can
once and all be done with this nonsense, unless Linux plans to deviate from
the standard?

	Thanks,

		Richard

-----Original Message-----
From: Steven Blake [mailto:slblake@petri-meat.com]
Sent: 20 August 2003 05:58
To: David S. Miller
Cc: netdev@oss.sgi.com; linux-net@vger.kernel.org
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices


On Tue, 2003-08-19 at 13:53, David S. Miller wrote:

> BTW, this ARP source address algorithm we use comes from
> ipv6, it would be instructive to go and see why they do
> things the way they do.

Are you sure?  See below:

========================================================================

RFC 2461              Neighbor Discovery for IPv6          December 1998


4.3.  Neighbor Solicitation Message Format

   Nodes send Neighbor Solicitations to request the link-layer address
   of a target node while also providing their own link-layer address to
   the target.  Neighbor Solicitations are multicast when the node needs
   to resolve an address and unicast when the node seeks to verify the
   reachability of a neighbor.

         0                   1                   2                   3
         0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        |     Type      |     Code      |          Checksum             |
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        |                           Reserved                            |
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        |                                                               |
        +                                                               +
        |                                                               |
        +                       Target Address                          +
        |                                                               |
        +                                                               +
        |                                                               |
        +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
        |   Options ...
        +-+-+-+-+-+-+-+-+-+-+-+-

   IP Fields:

      Source Address
                     Either an address assigned to the interface from
                     which this message is sent or (if Duplicate Address
                     Detection is in progress [ADDRCONF]) the
                     unspecified address.

      Destination Address
                     Either the solicited-node multicast address
                     corresponding to the target address, or the target
                     address.

      Hop Limit      255

      Authentication Header
                     If a Security Association for the IP Authentication
                     Header exists between the sender and the
                     destination address, then the sender SHOULD include
                     this header.





Narten, et. al.             Standards Track                    [Page 21]

========================================================================


Regards,

// Steve
