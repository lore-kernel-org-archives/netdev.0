From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/1] Defer skb allocation for both mergeable buffers
	and big packets in virtio_net
Date: Mon, 23 Nov 2009 08:18:08 -0800
Message-ID: <1258993088.5022.30.camel@localhost.localdomain>
References: <1258697745.7416.20.camel@localhost.localdomain>
	 <4B063509.10006@gmail.com> <1258734101.11049.1.camel@localhost.localdomain>
	 <20091123094323.GA3748@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Avi Kivity <avi@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20091123094323.GA3748@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-11-23 at 11:43 +0200, Michael S. Tsirkin wrote:

> should be !npage->private
> and nesting is too deep here:
> this is cleaner in a give_a_page subroutine
> as it was.

This will be addressed with Rusty's comment.


> > +		/* use private to chain big packets */
> 
> packets? or pages?

Will change it to chain pages for big packets

> > +		p->private = (unsigned long)0;
> 
> the comment is not really helpful:
> you say you use private to chain but 0 does not
> chain anything. You also do not need the cast to long?

Ok.

> > +	if (len > (PAGE_SIZE - f->page_offset))
> 
> brackets around math are not needed.

OK.

> typo
> 
> > +			 * header and data */
Got it.

> please think of a way to get rid of magic constants like 6 and 2
> here and elsewhere.

Will do.

> replace MAX_SKB_FRAGS + 2 with something symbolic? We have it in 2 palces now.
> And comment.

Ok, I can change it.

> terrible goto based loop
> move stuff into subfunction, it will be much
> more manageable, and convert this to a simple
> for loop.

Will change it to different functions based on Rusty's comment.

> and here it is MAX_SKB_FRAGS + 1

I think I should use MAX_SKB_FRAGS + 2 instead. Now I only use
MAX_SKB_FRAGS + 1 but allocated + 2.

> > +				page->private = (unsigned long)first_page;
> > +				first_page = page;
> > +				if (--i == 1) {
> 
> this is pretty hairy ... has to be this way?
> What you are trying to do here
> is fill buffer with pages, in a loop, with first one
> using a partial page, and then add it.
> Is that it?
Yes.

> So please code this in a straight forward manner.
> it should be as simple as:

> 	offset = XXX
> 	for (i = 0; i < MAX_SKB_FRAGS + 2; ++i) {
> 		
> 		sg_set_buf(sg + i, p + offset, PAGE_SIZE - offset);
> 		offset = 0;
> 
> 	}
Ok, looks more neat.

> space around +
> sg + 1 here is same as &sg[i] in fact?

Ok.

> callback -> destructor?

Ok.

I will integrate these comments with Rusty's and resubmit the patch set.

Thanks
Shirley

