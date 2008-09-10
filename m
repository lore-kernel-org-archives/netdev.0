From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: Distributed storage release.
Date: Thu, 11 Sep 2008 01:51:44 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0809110054020.1542@titan.stealer.net>
References: <20080909113817.GA14005@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080909113817.GA14005@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 9 Sep 2008, Evgeniy Polyakov wrote:

> I am pleased to announce new Distributed Storage (DST) project release.

Hi,

I just had another quick random look over it and found a small memory
leak in an error path, that was already present in your last post, but I
didn't notice. Also there still seem to be some non-critical style
issues, like an explicit continue at then end of a loop, but I didn't
bother to catch them this time.

Sven

> +static void *dst_crypto_thread_init(void *data)
> +{
> +	struct dst_node *n = data;
> +	struct dst_crypto_engine *e;
> +	int err = -ENOMEM;
> +
> +	e = kzalloc(sizeof(struct dst_crypto_engine), GFP_KERNEL);
> +	if (!e)
> +		goto err_out_exit;
> +	e->src = kzalloc(sizeof(struct scatterlist) * 2 * n->max_pages,
> +			GFP_KERNEL);
> +	if (!e->src)
> +		goto err_out_free;
> +
> +	e->dst = e->src + n->max_pages;
> +
> +	err = dst_crypto_engine_init(e, n);
> +	if (err)
> +		goto err_out_free;
> +
> +	return e;
> +
> +err_out_free:
> +	kfree(e->src);

You leak the memory allocated for e here.

> +err_out_exit:
> +	return ERR_PTR(err);
> +}
