From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH 1/2] virtio-net: Verify page list size before fitting
 into skb
Date: Wed, 28 Sep 2011 15:19:42 +0300
Message-ID: <1317212382.7213.21.camel@lappy>
References: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
	 <20110926184445.GA22278@redhat.com> <1317065842.20885.3.camel@lappy>
	 <20110926195541.GA23086@redhat.com> <1317105842.3467.3.camel@lappy>
	 <20110927070034.GB4690@redhat.com> <1317122429.3467.5.camel@lappy>
	 <20110927123719.GB11276@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110927123719.GB11276@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-09-27 at 15:37 +0300, Michael S. Tsirkin wrote:
> On Tue, Sep 27, 2011 at 02:20:29PM +0300, Sasha Levin wrote:
> > On Tue, 2011-09-27 at 10:00 +0300, Michael S. Tsirkin wrote:
> > > >               skb = page_to_skb(vi, page, len);
> > > >               ...
> > > 
> > > Sorry I don't get it yet. Where is mergeable ignored here?
> > 
> > The NULL deref happens in page_to_skb(), before merge buffers are
> > handled.
> 
> The len here is a single buffer length, so for mergeable
> buffers it is <= the size of the buffer we gave to hardware,
> which is PAGE_SIZE.
> 
>         err = virtqueue_add_buf_single(vi->rvq, page_address(page),
>                                        PAGE_SIZE, false, page, gfp);
>  
> 
> Unless of course we are trying to work around broken hardware again,
> which I don't have a problem with, but should probably
> get appropriate comments in code and trigger a warning.
> 
> > I'll test it and see if it's really the case.

I've verified it with VIRTIO_NET_F_MRG_RXBUF set, and we still get the
NULL deref.



-- 

Sasha.
