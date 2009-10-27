From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH] fib_hash: improve route deletion scaling on interface
 drop with lots of interfaces
Date: Tue, 27 Oct 2009 23:07:57 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0910272251170.3059@u.domain.uli>
References: <20091027000302.GA3141@kvack.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:34148 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932212AbZJ0VH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2009 17:07:56 -0400
In-Reply-To: <20091027000302.GA3141@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 26 Oct 2009, Benjamin LaHaise wrote:

> Hi folks,
> 
> Below is a patch to improve the scaling of interface destruction in 
> fib_hash.  The general idea is to tie the fib_alias structure into a 
> list off of net_device and walk that list during a fib_flush() caused 
> by an interface drop.  This makes the resulting flush only have to walk 
> the number of routes attached to an interface rather than the number of 
> routes attached to all interfaces at the expense of a couple of additional 
> pointers in struct fib_alias.

	May be this can not work for multipath routes because
you consider only the first device (fib_dev). Also nh_dev is
optional, not every route has device, so you should add checks
for dev ! NULL.

> @@ -516,6 +517,10 @@ static int fn_hash_insert(struct fib_table *tb, struct fib_config *cfg)
>  	new_fa->fa_type = cfg->fc_type;
>  	new_fa->fa_scope = cfg->fc_scope;
>  	new_fa->fa_state = 0;
> +	new_fa->fa_fib_node = f;
> +	new_fa->fa_fz = fz;
> +
> +	dev = fi->fib_dev;

Regards

--
Julian Anastasov <ja@ssi.bg>

