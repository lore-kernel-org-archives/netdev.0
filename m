From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: Wed, 25 Jun 2003 20:59:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030625.205941.41631020.davem@redhat.com>
References: <20030625.143334.85380461.davem@redhat.com>
	<20030626035824.D68B62C147@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, netdev@oss.sgi.com, fcusack@samba.org,
   carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
In-Reply-To: <20030626035824.D68B62C147@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rusty Russell <rusty@rustcorp.com.au>
   Date: Thu, 26 Jun 2003 13:57:09 +1000
   
   Frankly, I'm amazed anyone sees reordering in real life...

Many paths on the internet are quite reordered, this is
the first thing.  In fact, I claim that any TCP stack that
doesn't do reordering detection is busted performance wise.

The second thing is that network cards can and do reorder packets.
Some PCMCIA cards do this just for fun.  And ethernet _DOES NOT_
guarentee non-reordering.  At a minumum, a card can use QoS values to
reorder receive of a given packet, it can also use this to reorder
transmit.  Our packet schedulers do this on a software level.

If you need ordering, you need sequence numbers in your
protocol if you wish to operate over these mediums.

The case where SMP causes out-of-order packet delivery is just
academic compared to the non-local sources of reordering
mentioned above.
