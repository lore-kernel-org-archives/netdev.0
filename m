From: jamal <hadi@cyberus.ca>
Subject: RE: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 12:37:06 -0400
Message-ID: <1119458226.6918.142.camel@localhost.localdomain>
References: <200506221623.j5MGNkxS001340@guinness.s2io.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Donald Becker'" <becker@scyld.com>, "'Andi Kleen'" <ak@suse.de>,
        "'Rick Jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@neterion.com>
In-Reply-To: <200506221623.j5MGNkxS001340@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-22-06 at 09:23 -0700, Leonid Grossman wrote:
> > 
> > See the comment above. We decide if a packet is multicast vs. 
> > unicast, IP vs. other at approximately 
> > interrupt/"rx_copybreak" time.  Very few NIC provide this 
> > info in status bits, so we end up looking at the packet 
> > header.  That read moves the previously known-uncached data 
> > (after all, it was just came in from a bus write) into the L1 
> > cache for the CPU handling the device.  Once it's there, the 
> > copy is almost free.
> 
> What status bits a NIC has to provide, in order for the stack to avoid
> touching headers?
> In our case, the headers are separated by the hardware so ideally we would
> like to avoid any header processing altogether,
> and reduce the number of cache misses.
> 

Provide metadata that can be used to totaly replace eth_type_trans()
i.e answer the questions: is it multi/uni/broadcast, is the packet for
us (you would need to be programmed with what for us means), Is it IP,
ARP etc. I am sure any standard NIC these days can do a subset of these
 You want to go one step further then allow the user to download a
number of filters and tell you what tag you should put on the descriptor
when sending the packet to user space on a match or mismatch. 
If say you allowed 1024 such filters (not very different from the
current multicast filters), you could cut down a lot of CPU time.

cheers,
jamal
