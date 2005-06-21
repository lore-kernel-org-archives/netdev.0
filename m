From: Donald Becker <becker@scyld.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 21 Jun 2005 15:22:49 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0506211507110.21812-100000@bluewest.scyld.com>
References: <p73oe9zbcx0.fsf@verdi.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rick Jones <rick.jones2@hp.com>, <netdev@oss.sgi.com>, <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <p73oe9zbcx0.fsf@verdi.suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 21 Jun 2005, Andi Kleen wrote:

> Rick Jones <rick.jones2@hp.com> writes:
> 
> > > Actually, it has a _HUGE_ _HUGE_ impact.  If you pass the big buffer
> > > up, the receiving socket gets charged for the size of the huge buffer,
> > > not for just the size of the packet contained within.  This makes
> > > sockets get overcharged for data reception, and it can cause all kinds
> > > of performance problems.
> > 
> > Then copy when the socket is about to fill with overhead bytes?

Or better, predict when the frame you are currently stuffing into the 
queue will be there when the queue fills up.  And then use the same 
crystal ball to...
 
> Mostly because it is the only sane way to handle devices with very big
> MTU. But it turns off all kinds of fast paths before it happens, I
> guess that is what David was refering too.
> 
> However I suspect the cut-off points with rx-copybreak in common driver 
> have been  often tuned before that code was introduced and it might
> be worth to do some retesting.

Most of that analysis and tuning was done in the 1996-99 timeframe.  

While much has changed since then, the same basic parameters remain
   - cache line size
   - frame header size (MAC+IP+ProtocolHeader)
   - hot cache lines from copying or type classification
   - cold memory lines from PCI writes

I suspect you'll find that a good rx_copybreak is pretty much the same as 
it was when I did the original evaluation.

If you are looking for an area that has changed: the hidden cost of 
maintaining consistent cache lines on SMP systems is far higher than it 
was back in the days of the Pentium Pro.

Donald Becker				becker@scyld.com
Scyld Software				A Penguin Computing company
914 Bay Ridge Road, Suite 220		www.scyld.com
Annapolis MD 21403			410-990-9993
