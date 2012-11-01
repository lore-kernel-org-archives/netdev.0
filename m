From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/9] net: xfrm: use this_cpu_ptr per-cpu helper
Date: Thu, 1 Nov 2012 11:41:36 +0800
Message-ID: <20121101034136.GA27343@gondor.apana.org.au>
References: <509109F9.3030904@gmail.com>
 <0000013ab7e4a640-60bd5b38-a1fc-4730-b918-4109211ffea0-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei88@gmail.com>, steffen.klassert@secunet.com,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0000013ab7e4a640-60bd5b38-a1fc-4730-b918-4109211ffea0-000000@email.amazonses.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31, 2012 at 05:35:46PM +0000, Christoph Lameter wrote:
> On Wed, 31 Oct 2012, Shan Wei wrote:
> 
> > -
> >  	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
> >  		struct crypto_comp *tfm;
> >
> >  		tfms = pos->tfms;
> > -		tfm = *per_cpu_ptr(tfms, cpu);
> > +
> > +		/* This can be any valid CPU ID so we don't need locking. */
> > +		tfm = *this_cpu_ptr(tfms);
> 
> It would be better to use
> 
> 	this_cpu_read(tfms)
> 
> since that would also make it atomic vs interrupts. The above code (both
> original and modified) could determine a pointer to a per cpu structure
> and then take an interrupt which would move the task. On return we would
> be accessing the per cpu variable of another processor.

Please refer to the comment in the patch above.

But I think the patch is wrong anyway because it would introduce
a warning, no?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
