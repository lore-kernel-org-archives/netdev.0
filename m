From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 11:00:56 -0700
Message-ID: <200506221801.j5MI11xS021866@guinness.s2io.com>
References: <1119458226.6918.142.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'Donald Becker'" <becker@scyld.com>, "'Andi Kleen'" <ak@suse.de>,
        "'Rick Jones'" <rick.jones2@hp.com>, <netdev@oss.sgi.com>,
        <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <hadi@cyberus.ca>
In-Reply-To: <1119458226.6918.142.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: jamal [mailto:hadi@cyberus.ca] 
> Sent: Wednesday, June 22, 2005 9:37 AM
> To: Leonid Grossman
> Cc: 'Donald Becker'; 'Andi Kleen'; 'Rick Jones'; 
> netdev@oss.sgi.com; davem@redhat.com
> Subject: RE: RFC: NAPI packet weighting patch
> 
> On Wed, 2005-22-06 at 09:23 -0700, Leonid Grossman wrote:
> > > 
> > > See the comment above. We decide if a packet is multicast vs. 
> > > unicast, IP vs. other at approximately interrupt/"rx_copybreak" 
> > > time.  Very few NIC provide this info in status bits, so 
> we end up 
> > > looking at the packet header.  That read moves the previously 
> > > known-uncached data (after all, it was just came in from a bus 
> > > write) into the L1 cache for the CPU handling the device. 
>  Once it's 
> > > there, the copy is almost free.
> > 
> > What status bits a NIC has to provide, in order for the 
> stack to avoid 
> > touching headers?
> > In our case, the headers are separated by the hardware so 
> ideally we 
> > would like to avoid any header processing altogether, and 
> reduce the 
> > number of cache misses.
> > 
> 
> Provide metadata that can be used to totaly replace 
> eth_type_trans() i.e answer the questions: is it 
> multi/uni/broadcast, is the packet for us (you would need to 
> be programmed with what for us means), Is it IP, ARP etc. I 
> am sure any standard NIC these days can do a subset of these  
> You want to go one step further then allow the user to 
> download a number of filters and tell you what tag you should 
> put on the descriptor when sending the packet to user space 
> on a match or mismatch. 
> If say you allowed 1024 such filters (not very different from 
> the current multicast filters), you could cut down a lot of CPU time.


Well, this is all supported in the hardware. 
The number of filters is only 256 (not 1024) for direct match, but it is
unlimited for a hash match.
Of course, the upper layer still needs to be able to take advantage of the
filters...

Outside of the filters capability, from the (granted, pretty limited)
testing we see some noticeable improvement from providing status bits but it
is not as big as I would expect,
It looks like the headers are still being touched somewhere... We will look
at this some more.

Thanks, Leonid

> 
> cheers,
> jamal
> 
> 
