From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: Re: [RFC][PATCH][XFRM][1/5] extension to XFRM for dynamic endpoint update (MIGRATE)
Date: Fri, 02 Feb 2007 20:47:20 +0900
Message-ID: <20070202203550.E2F3.SHINTA@sfc.wide.ad.jp>
References: <20070201113017.E2BA.SHINTA@sfc.wide.ad.jp> <Pine.LNX.4.64.0702010937250.8524@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:35367 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbXBBLrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Feb 2007 06:47:25 -0500
In-Reply-To: <Pine.LNX.4.64.0702010937250.8524@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear James,

Thank you for your comments. Please find my comments inline.

On Thu, 1 Feb 2007 09:45:18 -0500 (EST)
James Morris <jmorris@namei.org> wrote:

> On Thu, 1 Feb 2007, Shinta Sugimoto wrote:
> 
> 
> > +int xfrm_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
> > +		 struct xfrm_migrate *m, int num_migrate)
> > +{
> > +	int i, err, nx_cur = 0, nx_new = 0;
> > +	struct xfrm_policy *pol = NULL;
> 
> [...]
> 
> > +donothing:
> > +	if (pol)
> > +		xfrm_pol_put(pol);
> 
> If you reach 'donothing', pol must be NULL, so you don't need to check for 
> it before xfrm_pol_put().

Yes, you are right. I will delete unnecessary null-check and xfrm_pol_put().

> 
> 
> > +#ifdef CONFIG_XFRM_MIGRATE
> > +static struct xfrm_algo *xfrm_algo_solidclone(struct xfrm_algo *orig)
> > +{
> > +	struct xfrm_algo *a;
> > +	a = kmalloc(sizeof(*orig) + orig->alg_key_len, GFP_KERNEL);
> > +	if (a)
> > +		memcpy(a, orig, sizeof(*orig) + orig->alg_key_len);
> 
> Use kmemdup() ?

I see. I will replace sets of kmalloc and memcpy with kmemdup().

> 
> 
> > +        if (orig->encap) {
> > +		x->encap = kmalloc(sizeof(*x->encap), GFP_KERNEL);
> > +		if (!x->encap)
> > +			goto error;
> > +		memcpy(x->encap, orig->encap, sizeof(*x->encap));
> > +	}
> > +
> > +	if (orig->coaddr) {
> > +		x->coaddr = kmalloc(sizeof(*x->coaddr), GFP_KERNEL);
> > +		if (!x->coaddr)
> > +			goto error;
> > +		memcpy(x->coaddr, orig->coaddr, sizeof(*x->coaddr));
> > +	}
> 
> Ditto.
> 
> > +EXPORT_SYMBOL(xfrm_state_clone);
> 
> Why not EXPORT_SYMBOL_GPL ?
> (for all of your exports).

Actually I don't have specific preference on either EXPORT_SYMBOL or
EXPORT_SYMBOL_GPL.  It seemed to me that other functions defined in
files under net/xfrm/ are using EXPORT_SYMBOL, so I followed that.
Do you think EXPORT_SYMBOL_GPL is more appropriate in this case?


Regards,
Shinta

