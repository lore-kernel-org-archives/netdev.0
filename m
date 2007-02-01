From: James Morris <jmorris@namei.org>
Subject: Re: [RFC][PATCH][XFRM][1/5] extension to XFRM for dynamic endpoint
 update (MIGRATE)
Date: Thu, 1 Feb 2007 09:45:18 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0702010937250.8524@d.namei>
References: <20070201113017.E2BA.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:46555 "EHLO
	mail2.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422903AbXBAOpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 09:45:20 -0500
In-Reply-To: <20070201113017.E2BA.SHINTA@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 1 Feb 2007, Shinta Sugimoto wrote:


> +int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
> +		 struct xfrm_migrate *m, int num_migrate)
> +{
> +	int i, err, nx_cur = 0, nx_new = 0;
> +	struct xfrm_policy *pol = NULL;

[...]

> +donothing:
> +	if (pol)
> +		xfrm_pol_put(pol);

If you reach 'donothing', pol must be NULL, so you don't need to check for 
it before xfrm_pol_put().


> +#ifdef CONFIG_XFRM_MIGRATE
> +static struct xfrm_algo *xfrm_algo_solidclone(struct xfrm_algo *orig)
> +{
> +	struct xfrm_algo *a;
> +	a = kmalloc(sizeof(*orig) + orig->alg_key_len, GFP_KERNEL);
> +	if (a)
> +		memcpy(a, orig, sizeof(*orig) + orig->alg_key_len);

Use kmemdup() ?


> +        if (orig->encap) {
> +		x->encap = kmalloc(sizeof(*x->encap), GFP_KERNEL);
> +		if (!x->encap)
> +			goto error;
> +		memcpy(x->encap, orig->encap, sizeof(*x->encap));
> +	}
> +
> +	if (orig->coaddr) {
> +		x->coaddr = kmalloc(sizeof(*x->coaddr), GFP_KERNEL);
> +		if (!x->coaddr)
> +			goto error;
> +		memcpy(x->coaddr, orig->coaddr, sizeof(*x->coaddr));
> +	}

Ditto.

> +EXPORT_SYMBOL(xfrm_state_clone);

Why not EXPORT_SYMBOL_GPL ?
(for all of your exports).




- James
-- 
James Morris
<jmorris@namei.org>
