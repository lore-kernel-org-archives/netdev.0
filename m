From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC] defer skb allocation in virtio_net -- mergable buff part
Date: Mon, 24 Aug 2009 10:51:50 -0700
Message-ID: <1251136310.588.2.camel@localhost.localdomain>
References: <1250145231.6653.29.camel@localhost.localdomain>
	 <4A880DFE.2040507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A880DFE.2040507@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Avi,

Thanks for you review. I was on vacation last week.

On Sun, 2009-08-16 at 16:47 +0300, Avi Kivity wrote:
> Alternatives include:
> - store the link in the page itself
> - have an array of pages per list element instead of just one pointer
> - combine the two, store an array of page pointers in one of the free
> pages
> - use the struct page::lru member
> 
> The last is the most traditional and easiest so I'd recommend it
> (though 
> it still takes the cacheline hit).

I prefer the combine of the two. But I will compare the performance
differences if no much difference, we can use the easiest one.

> > +static struct page_list *get_a_free_page(struct virtnet_info *vi,
> gfp_t gfp_mask)
> > +{
> > +     struct page_list *plist;
> > +
> > +     if (list_empty(&vi->freed_pages)) {
> > +             plist = kmalloc(sizeof(struct page_list), gfp_mask);
> > +             if (!plist)
> > +                     return NULL;
> > +             list_add_tail(&plist->list,&vi->freed_pages);
> > +             plist->page = alloc_page(gfp_mask);
> >    
> 
> What if the allocation fails here?

It is handled by the caller.

Thanks
Shirley

