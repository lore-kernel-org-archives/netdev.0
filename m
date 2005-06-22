From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 19:05:49 +0200
Message-ID: <20050622170549.GV14251@wotan.suse.de>
References: <Pine.LNX.4.44.0506211642290.21812-100000@bluewest.scyld.com> <200506221623.j5MGNkxS001340@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Donald Becker'" <becker@scyld.com>, "'Andi Kleen'" <ak@suse.de>,
        "'Rick Jones'" <rick.jones2@hp.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@neterion.com>
Content-Disposition: inline
In-Reply-To: <200506221623.j5MGNkxS001340@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 22, 2005 at 09:23:41AM -0700, Leonid Grossman wrote:
> 
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

To avoid it completely is pretty hard - you would need to supply
nearly everything in the header.

But when you supply L2 protocol/ and unicast/broadcast/multicast information
and if the packet is destined to the localhost or not then the 
headers can be gotten with a prefetch early and then when 
the header is later processed then it might be with some luck
already in cache.

BTW quite a few modern NICs provide this information actually contrary
to what Donald stated (sometimes with restrictions like only
works without multicast), but it hasn't been widely used yet.

-Andi
