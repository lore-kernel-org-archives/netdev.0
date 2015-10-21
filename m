From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] xfrm: Fix unaligned access in
 xfrm_notify_sa() for DELSA
Date: Wed, 21 Oct 2015 06:54:42 -0400
Message-ID: <20151021105442.GM6948@oracle.com>
References: <cover.1445286755.git.sowmini.varadhan@oracle.com>
 <65f37efeff5af105c89493dda4f38c61e4cd495f.1445286755.git.sowmini.varadhan@oracle.com>
 <20151021065704.GM7701@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	dhowells@redhat.com, davem@davemloft.net, zohar@linux.vnet.ibm.com,
	David.Woodhouse@intel.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151021065704.GM7701@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/21/15 08:57), Steffen Klassert wrote:
> > --- a/net/xfrm/xfrm_user.c
> > +++ b/net/xfrm/xfrm_user.c
> > @@ -2659,7 +2659,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
> >  		if (attr == NULL)
> >  			goto out_free_skb;
> >  
> > -		p = nla_data(attr);
> > +		p = PTR_ALIGN(nla_data(attr), __alignof__(*p));
> 
> Hm, this breaks userspace notifications on 64-bit systems.
> Userspace expects this to be aligned to 4, with your patch
> it is aligned to 8 on 64-bit.
> 
> Without your patch I get the correct notification when deleting a SA:
> 

But __alignof__(*p) is 8 on sparc, and without the patch I get
all types of unaligned access. So what do you suggest as the fix?

(and openswan/pluto dont flag any errors with the patch, which is
a separate bug).

--Sowmini
