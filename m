From: Peter Chubb <peter@chubb.wattle.id.au>
Subject: Re: Making the NS83820 usable on IA64
Date: Wed, 17 Mar 2004 15:33:03 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16471.54527.703181.721517@wombat.chubb.wattle.id.au>
References: <16471.52400.222262.824746@wombat.disy.cse.unsw.edu.au>
	<4057D1B8.9090508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, linux-ia64@vger.kernel.org,
        linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4057D1B8.9090508@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>>>>> "Jeff" == Jeff Garzik <jgarzik@pobox.com> writes:

Jeff> Peter Chubb wrote:
>> With the current NS83820 driver and IP stack implementation, the
>> IA64 kernel spends 99.9% of its time in the unaligned access trap
>> handler when the network starts getting busy.  When I raised this
>> issue before, the idea of realigning the skbuf data in the driver
>> was scouted; therefore I submit this patch for your approval.  It
>> makes the driver usable, and doesn't seem to affect anything else.

Jeff> More likely, you need to play around with ns83820.c's
Jeff> skb_reserve() code, in rx_refill():

Unfortunately the dp83820 won't dma to anything other than a 64-bit
aligned packet.  See table 3-2:

  offset  tag		description
   0004h  bufptr	32- or 64- bit pointer to the first fragment
			or buffer.  In transmit descriptors the buffer
			can begin on any byte boundary.  In receive
			descriptors, the buffer must be aligned on
			 a 64-bit boundary.

--
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
