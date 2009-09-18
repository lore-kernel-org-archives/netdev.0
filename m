From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC] defer skb allocation in virtio_net -- mergable buff part
Date: Fri, 18 Sep 2009 10:04:05 -0700
Message-ID: <1253293445.4611.9.camel@localhost.localdomain>
References: <1250145231.6653.29.camel@localhost.localdomain>
	 <20090825114143.GA13884@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756399AbZIRREI@vger.kernel.org>
In-Reply-To: <20090825114143.GA13884@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

I am working on the patch to address the question you raised below. I am
adding one more function -- destroy_buf in virtqueue_ops, so we don't
need to maintain the list of pending buffers in upper layer (like
virtio_net), when the device is shutdown or removed, this buffer free
func will be called to release all pending buffers in virtio_ring on
behalf of virtio_net.

The rest of comments are minor. The new patch will defer skb allocation
for both mergable and none-mergable buffers.

Thanks
Shirley


On Tue, 2009-08-25 at 14:41 +0300, Michael S. Tsirkin wrote:
> >  #define VIRTNET_SEND_COMMAND_SG_MAX    2
> >  
> > +struct page_list
> > +{
> 
> Kernel style is "struct page_list {".
> Also, prefix with virtnet_?
> 
> > +     struct page *page;
> > +     struct list_head list;
> > +};
> > +
> >  struct virtnet_info
> >  {
> >       struct virtio_device *vdev;
> > @@ -72,6 +79,8 @@ struct virtnet_info
> >  
> >       /* Chain pages by the private ptr. */
> >       struct page *pages;
> 
> Do we need the pages list now? Can we do without?
> 
> Pls document fields below.
> 
> > +     struct list_head used_pages;
> 
> Seems a waste to have this list just for dev down.
> Extend virtio to give us all buffers from vq
> on shutdown?
> 
