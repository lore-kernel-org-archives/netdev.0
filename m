From: James Carlson <carlson@workingcode.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Thu, 26 Jun 2003 06:47:26 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16122.53054.421234.711859@h006008986325.ne.client2.attbi.com>
References: <20030625.205941.41631020.davem@redhat.com>
	<20030626085307.096652C0B4@lists.samba.org>
	<20030626.015533.77059614.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, paulus@samba.org, netdev@oss.sgi.com,
   fcusack@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: David S. Miller's message of 26 June 2003 01:55:33
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller writes:
>    From: Rusty Russell <rusty@rustcorp.com.au>
>    Date: Thu, 26 Jun 2003 18:17:45 +1000
>    
>    If the first one isn't happening, this patch is doubly useless 8)
> 
> It does happen, but so does reordering on ethernet itself.

That's nonsense, and it's directly counter to all of the 802
standards.  Please explain how reordering on a single wire could ever
take place.

Reordering *requires* that you have something like a router in the
path.  It's an issue for a network or transport layer protocol to
consider, but it's not a link-layer issue.

If you have Ethernet interfaces that reorder packets between a given
pair of stations, then those interfaces are just simply broken.

>From IEEE Std 802.1D, 1998:

6.3.3 Frame misordering
    The MAC Service does not permit the reordering of frames with a
    given user priority for a given combination of destination address
    and source address. MA_UNITDATA.indication service primitives
    corresponding to MA_UNITDATA.request primitives, with the same
    requested priority and for the same combination of destination and
    source addresses, are received in the same order as the request
    primitives were processed.

Here are some excerpts from IEEE Std 802.3-2002:

1.4.94 Conversation: A set of MAC frames transmitted from one end
    station to another, where all of the MAC frames form an ordered
    sequence, and where the communicating end stations require the
    ordering to be maintained among the set of MAC frames
    exchanged. (See IEEE 802.3 Clause 43.)

43.2.1 Principles of Link Aggregation

  Link Aggregation allows a MAC Client to treat a set of one or more
  ports as if it were a single port. In doing so, it employs the
  following principles and concepts:
[...]

f) Frame ordering must be maintained for certain sequences of frame
   exchanges between MAC Clients (known as conversations, see
   1.4). The Distributor ensures that all frames of a given
   conversation are passed to a single port. For any given port, the
   Collector is required to pass frames to the MAC Client in the order
   that they are received from that port. The Collector is otherwise
   free to select frames received from the aggregated ports in any
   order. Since there are no means for frames to be misordered on a
   single link, this guarantees that frame ordering is maintained for
   any conversation.
[...]
43.2.3 Frame Collector
     A Frame Collector is responsible for receiving incoming frames
     (i.e., AggMuxN:MA_DATA.indications) from the set of individual
     links that form the Link Aggregation Group (through each link s
     associated Aggregator Parser/Multiplexer) and delivering them to
     the MAC Client. Frames received from a given port are delivered
     to the MAC Client in the order that they are received by the
     Frame Collector. Since the Frame Distributor is responsible for
     maintaining any frame ordering constraints, there is no
     requirement for the Frame Collector to perform any reordering of
     frames received from multiple links.
[...]
Annex 43A

a) Frame duplication is not permitted.
b) Frame ordering must be preserved in aggregated links. Strictly, the
   MAC service specication (ISO/IEC 15802-1) states that order must be
   preserved for frames with a given SA, DA, and priority; however,
   this is a tighter constraint than is absolutely necessary. There
   may be multiple, logically independent conversations in progress
   between a given SA-DA pair at a given priority; the real
   requirement is to maintain ordering within a conversation, though
   not necessarily between conversations.

-- 
James Carlson                                  <carlson@workingcode.com>
