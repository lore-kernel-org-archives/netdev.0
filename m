From: Roland Dreier <roland@topspin.com>
Subject: Re: Advice needed on IP-over-InfiniBand driver
Date: Mon, 27 Sep 2004 21:41:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <52r7onc8ev.fsf@topspin.com>
References: <52fz5esxx6.fsf@topspin.com>
	<20040919140133.60ea3fb3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040919140133.60ea3fb3.davem@davemloft.net> (David S.
 Miller's message of "Sun, 19 Sep 2004 14:01:33 -0700")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've been mulling over the previous advice I got and reading over the
networking code, and I hope I have some more intelligent questions
now.  It seems I really have two somewhat independent issues to
resolve with respect to IP-over-IB address resolution:

 - IPoIB adds a second InfiniBand-specific path record lookup after
   the normal ARP/ND lookup.  I think I have a handle on how this can
   be added to net/ipv4/arp.c.

 - For InfiniBand, the layer 2 header is built and parsed by the
   hardware without a chance for software to see it.  In fact, once we
   have completed the 2 stage resolution as described above, the
   network driver has to pass this path information to the IB hardware
   and get an "address handle" back, which it uses to actually send
   packets.  It seems the existing hard_header, hard_header_cache and
   header_cache_update are not really applicable.

   My ideal solution would be some way for the driver have the packets
   passed to its hard_start_xmit method with the address handle in the
   skb->cb field (or another field if it's acceptable/desirable to add
   a field for this to struct sk_buff -- I notice a number of
   #ifdef'ed fields in there already, but I'm not sure if that type of
   thing is just old cruft or still OK).

   Also it would be nice is that address handle could be taken
   directly from the struct neighbor -- after all, we should be able
   to get it without requiring the driver to do any lookup from HW
   address to address handle.

   Finally, address handles need to be freed eventually, and I
   don't see a way for a driver to find out when an ARP entry is being
   destroyed.  Am I missing something, or is this something else I'll
   need to add?  What would be an acceptable way to add this to the
   networking code?

I'd really appreciate another dose of cluestick...

Thanks,
  Roland
