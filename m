From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and avoid TX queue overrun through packet drop
Date: Mon, 04 Apr 2011 15:43:41 +0930
Message-ID: <87mxk6bl2i.fsf@rustcorp.com.au>
References: <20110318133311.GA20623@gondor.apana.org.au> <1300498915.3441.21.camel@localhost.localdomain> <1300730587.3441.24.camel@localhost.localdomain> <20110322113649.GA17071@redhat.com> <1300847204.3441.26.camel@localhost.localdomain> <87r59xbbr6.fsf@rustcorp.com.au> <20110324142822.GD12958@redhat.com> <87mxkjls61.fsf@rustcorp.com.au> <20110327075254.GA3776@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110327075254.GA3776@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 27 Mar 2011 09:52:54 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > Though IIRC, qemu's virtio barfs if the first descriptor isn't just the
> > hdr (barf...).
> 
> Maybe we can try fixing this before adding more flags,
> then e.g. publish used flag can be resued to also
> tell us layout is flexible. Or just add a feature flag for that.

We should probably do this at some stage, yes.

> > > 2. I didn't have time to work on virtio2 ideas presented
> > >    at the kvm forum yet, any takers?
> > 
> > I didn't even attend.
> 
> Hmm, right. But what was presented there was discussed on list as well:
> a single R/W descriptor ring with valid bit instead of 2 rings
> + a descriptor array.

I'll be happy when we reach the point that the extra cacheline is
hurting us :)

Then we should do direct descriptors w/ a cookie as the value to hand
back when finished.  That seems to be close to optimal.

> I agree absolutely that not all lessons has been learned,
> playing with different ring layouts would make at least
> an interesting paper IMO.

Yes, I'd like to see the results...

Thanks,
Rusty.
