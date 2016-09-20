From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 6/7] net: Generic resolver backend
Date: Tue, 20 Sep 2016 17:40:43 +0800
Message-ID: <20160920094043.GA21016@gondor.apana.org.au>
References: <1473895376-347096-7-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
        roopa@cumulusnetworks.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35127 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752159AbcITJkv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:40:51 -0400
Content-Disposition: inline
In-Reply-To: <1473895376-347096-7-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
>
> +       nrslv->params.head_offset = offsetof(struct net_rslv_ent, node);
> +       nrslv->params.key_offset = offsetof(struct net_rslv_ent, object);
> +       nrslv->params.key_len = key_len;
> +       nrslv->params.max_size = max_size;
> +       nrslv->params.min_size = 256;
> +       nrslv->params.automatic_shrinking = true;
> +       nrslv->params.obj_cmpfn = cmp_fn ? net_rslv_cmp : NULL;

This completely defeats the rhashtable inlining since that relies
on the parameter being constant.

Looking at your next patch you have exactly one user for this.  So
who is going to be the next user and do we really need all these
fields to be variable?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
