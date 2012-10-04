From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/3] virtio-net: correct capacity math on ring full
Date: Thu, 04 Oct 2012 09:54:01 +0930
Message-ID: <878vbn2ify.fsf@rustcorp.com.au>
References: <cover.1348824232.git.mst@redhat.com> <f2f7123534aefb33a7a233d9fec56de6e9eeed73.1348824232.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, avi@redhat.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <f2f7123534aefb33a7a233d9fec56de6e9eeed73.1348824232.git.mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> writes:
> Capacity math on ring full is wrong: we are
> looking at num_sg but that might be optimistic
> because of indirect buffer use.
>
> The implementation also penalizes fast path
> with extra memory accesses for the benefit of
> ring full condition handling which is slow path.
>
> It's easy to query ring capacity so let's do just that.

This path will reduce the actual queue use to worst-case assumptions.
With bufferbloat maybe that's a good thing, but it's true.

If we do this, the code is now wrong:

	/* This can happen with OOM and indirect buffers. */
	if (unlikely(capacity < 0)) {

Because this should now *never* happen.

But I do like the cleanup; returning capacity from add_buf() was always
hacky.  I've got an idea, we'll see what it looks like...

Cheers,
Rusty.
