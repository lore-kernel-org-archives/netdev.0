From: Steven Blake <slblake@petri-meat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: 20 Aug 2003 00:58:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061355487.1223.4.camel@photon>
References: <353568DCBAE06148B70767C1B1A93E625EAB5C@post.pc.aspectgroup.co.uk>
	 <20030819105307.0b0a6491.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819105307.0b0a6491.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

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
