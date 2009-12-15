From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 1/4] Defer skb allocation -- add destroy buffers
	function for virtio
Date: Wed, 16 Dec 2009 00:40:02 +0200
Message-ID: <20091215224002.GA27034@redhat.com>
References: <1258697359.7416.14.camel@localhost.localdomain> <1260821285.8716.7.camel@localhost.localdomain> <20091214202253.GG6150@redhat.com> <200912160906.12430.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760524AbZLOWnM@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200912160906.12430.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 16, 2009 at 09:06:12AM +1030, Rusty Russell wrote:
> On Tue, 15 Dec 2009 06:52:53 am Michael S. Tsirkin wrote:
> > On Mon, Dec 14, 2009 at 12:08:05PM -0800, Shirley Ma wrote:
> > > Hello Michael,
> > > 
> > > I agree with the comments (will have two patches instead of 4 based on
> > > Rusty's comments) except below one.
> > > 
> > > On Sun, 2009-12-13 at 12:26 +0200, Michael S. Tsirkin wrote:
> > > > That said - do we have to use a callback?
> > > > I think destroy_buf which returns data pointer,
> > > > and which we call repeatedly until we get NULL
> > > > or error, would be an a better, more flexible API.
> > > > This is not critical though.
> > > 
> > > The reason to use this is because in virtio_net remove, it has
> > > BUG_ON(vi->num != 0), which will be consistent with small skb packet. If
> > > we use NULL, error then we lose the track for vi->num, since we don't
> > > know how many buffers have been passed to ULPs or still unused.
> > > 
> > > Thanks
> > > Shirley
> > 
> > I dont insist, but my idea was
> > 
> > for (;;) {
> > 	b = vq->destroy(vq);
> > 	if (!b)
> > 		break;
> > 	--vi->num;
> > 	put_page(b);
> > }
> 
> In this case it should be called "get_unused_buf" or something.  But I like
> Shirley's approach here; destroy (with callback) accurately reflects the only
> time this can be validly used.
> 
> Cheers,
> Rusty.

I guess the actual requirement is that device must be
inactive.

As I said this is fine with me as well.
But I think the callback should get vq pointer besides the
data pointer, so that it can e.g. find the device if it needs to.
In case of virtio net this makes it possible
to decrement the outstanding skb counter in the callback.
Makes sense?

-- 
MST
