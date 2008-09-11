From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage release.
Date: Thu, 11 Sep 2008 08:23:46 +0400
Message-ID: <20080911042345.GA8570@2ka.mipt.ru>
References: <20080909113817.GA14005@2ka.mipt.ru> <alpine.LNX.2.00.0809110054020.1542@titan.stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.0809110054020.1542@titan.stealer.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sven.

On Thu, Sep 11, 2008 at 01:51:44AM +0200, Sven Wegener (sven.wegener@stealer.net) wrote:
> > +static void *dst_crypto_thread_init(void *data)
> > +{
> > +	struct dst_node *n = data;
> > +	struct dst_crypto_engine *e;
> > +	int err = -ENOMEM;
> > +
> > +	e = kzalloc(sizeof(struct dst_crypto_engine), GFP_KERNEL);
> > +	if (!e)
> > +		goto err_out_exit;
> > +	e->src = kzalloc(sizeof(struct scatterlist) * 2 * n->max_pages,
> > +			GFP_KERNEL);
> > +	if (!e->src)
> > +		goto err_out_free;
> > +
> > +	e->dst = e->src + n->max_pages;
> > +
> > +	err = dst_crypto_engine_init(e, n);
> > +	if (err)
> > +		goto err_out_free;
> > +
> > +	return e;
> > +
> > +err_out_free:
> > +	kfree(e->src);
> 
> You leak the memory allocated for e here.

Thanks a lot for pointing this out, I will fix it.

-- 
	Evgeniy Polyakov
