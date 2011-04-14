From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Thu, 14 Apr 2011 19:03:59 +0300
Message-ID: <20110414160359.GA11218@redhat.com>
References: <20110127.130240.104065182.davem@davemloft.net>
 <OF5CFD7B6A.4CBE4E3B-ON6525782B.0014DC5B-6525782B.001979CB@in.ibm.com>
 <20110202044222.GC3818@redhat.com>
 <201102091107.20270.rusty@rustcorp.com.au>
 <1299621444.25664.77.camel@localhost.localdomain>
 <1299637278.13202.61.camel@localhost.localdomain>
 <87fwqv4udl.fsf@rustcorp.com.au>
 <20110412200112.GA19729@redhat.com>
 <87bp09ax7a.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: habanero@linux.vnet.ibm.com, Shirley Ma <mashirle@us.ibm.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>, borntraeger@de.ibm.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87bp09ax7a.fsf@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 14, 2011 at 08:58:41PM +0930, Rusty Russell wrote:
> On Tue, 12 Apr 2011 23:01:12 +0300, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > On Thu, Mar 10, 2011 at 12:19:42PM +1030, Rusty Russell wrote:
> > > Here's an old patch where I played with implementing this:
> > 
> > ...
> > 
> > > 
> > > virtio: put last_used and last_avail index into ring itself.
> > > 
> > > Generally, the other end of the virtio ring doesn't need to see where
> > > you're up to in consuming the ring.  However, to completely understand
> > > what's going on from the outside, this information must be exposed.
> > > For example, if you want to save and restore a virtio_ring, but you're
> > > not the consumer because the kernel is using it directly.
> > > 
> > > Fortunately, we have room to expand:
> > 
> > This seems to be true for x86 kvm and lguest but is it true
> > for s390?
> 
> Yes, as the ring is page aligned so there's always room.
> 
> > Will this last bit work on s390?
> > If I understand correctly the memory is allocated by host there?
> 
> They have to offer the feature, so if the have some way of allocating
> non-page-aligned amounts of memory, they'll have to add those extra 2
> bytes.
> 
> So I think it's OK...
> Rusty.

To clarify, my concern is that we always seem to try to map
these extra 2 bytes, which thinkably might fail?

-- 
MST
