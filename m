From: James Carlson <carlson@workingcode.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Thu, 26 Jun 2003 06:51:30 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16122.53298.150512.793074@h006008986325.ne.client2.attbi.com>
References: <20030625.143334.85380461.davem@redhat.com>
	<20030626035824.D68B62C147@lists.samba.org>
	<20030625.205941.41631020.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, paulus@samba.org, netdev@oss.sgi.com,
   fcusack@samba.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: David S. Miller's message of 25 June 2003 20:59:41
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller writes:
>    From: Rusty Russell <rusty@rustcorp.com.au>
>    Date: Thu, 26 Jun 2003 13:57:09 +1000
>    
>    Frankly, I'm amazed anyone sees reordering in real life...
> 
> Many paths on the internet are quite reordered, this is
> the first thing.  In fact, I claim that any TCP stack that
> doesn't do reordering detection is busted performance wise.

Nobody's disputing that.  That's certainly true.  However, reordering
on a given wire does not happen.

> The second thing is that network cards can and do reorder packets.
> Some PCMCIA cards do this just for fun.

If so, then that needs to be taken up with the manufacturer.  That's a
rather severe design flaw that will prevent such a card from ever
being used for anything other than IP -- many other protocols *ASSUME*
that packets on a single wire cannot be reordered, including SNA, PPP
(!), and link aggregation, among others.

>  And ethernet _DOES NOT_
> guarentee non-reordering.

Please provide references.  802.1 MAC says otherwise.

>  At a minumum, a card can use QoS values to
> reorder receive of a given packet, it can also use this to reorder
> transmit.  Our packet schedulers do this on a software level.

Sure.  *If* QoS is present, then reordering between priority levels is
permissible.  However, reordering L2 frames at a given priority level
isn't.

> If you need ordering, you need sequence numbers in your
> protocol if you wish to operate over these mediums.
> 
> The case where SMP causes out-of-order packet delivery is just
> academic compared to the non-local sources of reordering
> mentioned above.

Not where it affects the correctness of the defined protocols.

-- 
James Carlson                                  <carlson@workingcode.com>
