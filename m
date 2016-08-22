From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] tun: Rename a jump label in update_filter()
Date: Mon, 22 Aug 2016 08:26:36 +0300
Message-ID: <20160822052635.GC1205@rapoport-lnx>
References: <566ABCD9.1060404@users.sourceforge.net>
 <9cf06275-924d-6c22-d8a8-f733a03cca23@users.sourceforge.net>
 <0c8d93e2-34cf-ca23-955e-999f424b3ab2@users.sourceforge.net>
 <20160822044048-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jason Wang <jasowang@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160822044048-mutt-send-email-mst@kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 22, 2016 at 04:41:11AM +0300, Michael S. Tsirkin wrote:
> On Sat, Aug 20, 2016 at 09:37:16AM +0200, SF Markus Elfring wrote:
> > From: Markus Elfring <elfring@users.sourceforge.net>
> > Date: Sat, 20 Aug 2016 09:00:34 +0200
> > 
> > Adjust a jump target according to the Linux coding style convention.
> > 
> > Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> 
> I don't have an opinion of this one. Which convention do you refer to?

Citing Documentation/CodingStyle:

Choose label names which say what the goto does or why the goto exists.  An
example of a good name could be "out_buffer:" if the goto frees "buffer".
Avoid using GW-BASIC names like "err1:" and "err2:".  Also don't name them after
the goto location like "err_kmalloc_failed:"

> 
> > ---
> >  drivers/net/tun.c | 5 ++---
> >  1 file changed, 2 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index a1aeccb..e249428 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -753,7 +753,7 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
> >  	for (; n < uf.count; n++) {
> >  		if (!is_multicast_ether_addr(addr[n].u)) {
> >  			err = 0; /* no filter */
> > -			goto done;
> > +			goto free_addr;
> >  		}
> >  		addr_hash_set(filter->mask, addr[n].u);
> >  	}
> > @@ -769,8 +769,7 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
> >  
> >  	/* Return the number of exact filters */
> >  	err = nexact;
> > -
> > -done:
> > +free_addr:
> >  	kfree(addr);
> >  	return err;
> >  }
> > -- 
> > 2.9.3
> 

