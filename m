From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 09:23:41 -0700
Message-ID: <200506221623.j5MGNkxS001340@guinness.s2io.com>
References: <Pine.LNX.4.44.0506211642290.21812-100000@bluewest.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'Rick Jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>,
        <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Donald Becker'" <becker@scyld.com>, "'Andi Kleen'" <ak@suse.de>
In-Reply-To: <Pine.LNX.4.44.0506211642290.21812-100000@bluewest.scyld.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> 
> See the comment above. We decide if a packet is multicast vs. 
> unicast, IP vs. other at approximately 
> interrupt/"rx_copybreak" time.  Very few NIC provide this 
> info in status bits, so we end up looking at the packet 
> header.  That read moves the previously known-uncached data 
> (after all, it was just came in from a bus write) into the L1 
> cache for the CPU handling the device.  Once it's there, the 
> copy is almost free.

What status bits a NIC has to provide, in order for the stack to avoid
touching headers?
In our case, the headers are separated by the hardware so ideally we would
like to avoid any header processing altogether,
and reduce the number of cache misses.

> 
> [[ Background: Yes, the allocating the new skbuff is very 
> expensive.  But we can either allocate a new, correctly-sized 
> skbuff to copy into, or allocate a new full-sized skbuff to 
> replace the one we will send to the Rx queue.  ]] 
>  
> > >    - cold memory lines from PCI writes
> > 
> > I suspect in '96 chipsets also didn't do as aggressive 
> prefetching as 
> > they do today.
> 
> Prefetching helps linear read bandwidth, but we shouldn't be 
> triggering it.  And I claim that cache line prefetching only 
> restores the relative balance between L1/L2 caches, otherwise 
> the long L2 cache lines would be very expensive with 
> bump-read-bump-read with linear scans through memory.
> 
> -- 
> Donald Becker				becker@scyld.com
> Scyld Software	 			Scyld Beowulf 
> cluster systems
> 914 Bay Ridge Road, Suite 220		www.scyld.com
> Annapolis MD 21403			410-990-9993
> 
> 
> 
