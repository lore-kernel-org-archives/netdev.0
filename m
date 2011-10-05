From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 2/2] virtio-net: Prevent NULL dereference
Date: Wed, 5 Oct 2011 16:59:42 -0200
Message-ID: <20111005185942.GB15444@redhat.com>
References: <1317220855-9352-1-git-send-email-levinsasha928@gmail.com>
 <1317220855-9352-2-git-send-email-levinsasha928@gmail.com>
 <20111003184037.GA22427@redhat.com>
 <1317822614.3676.0.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1317822614.3676.0.camel@lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 05, 2011 at 03:50:14PM +0200, Sasha Levin wrote:
> On Mon, 2011-10-03 at 20:40 +0200, Michael S. Tsirkin wrote:
> > On Wed, Sep 28, 2011 at 05:40:55PM +0300, Sasha Levin wrote:
> > > This patch prevents a NULL dereference when the user has passed a length
> > > longer than an actual buffer to virtio-net.
> > > 
> > > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > > Cc: "Michael S. Tsirkin" <mst@redhat.com>
> > > Cc: virtualization@lists.linux-foundation.org
> > > Cc: netdev@vger.kernel.org
> > > Cc: kvm@vger.kernel.org
> > > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > > ---
> > >  drivers/net/virtio_net.c |   12 +++++++++++-
> > >  1 files changed, 11 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > > index bde0dec..4a53d2a 100644
> > > --- a/drivers/net/virtio_net.c
> > > +++ b/drivers/net/virtio_net.c
> > > @@ -208,12 +208,22 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
> > >  		return NULL;
> > >  	}
> > >  
> > > -	while (len) {
> > > +	while (len && page) {
> > >  		set_skb_frag(skb, page, offset, &len);
> > >  		page = (struct page *)page->private;
> > >  		offset = 0;
> > >  	}
> > >  
> > > +	/*
> > > +	 * This is the case where we ran out of pages in our linked list, but
> > > +	 * supposedly have more data to read.
> > 
> > Again, let's clarify that this only happens with broken devices.
> 
> I think that the code within the if() makes it clear that it isn't the
> regular path.

It doesn't make it clear that this never happens in absence of bugs.

> -- 
> 
> Sasha.
