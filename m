From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 4/5] tun: vringfd xmit support.
Date: Mon, 07 Apr 2008 13:13:44 +0800
Message-ID: <E1Jijfs-0004Lo-00@gondolin.me.apana.org.au>
References: <200804052206.33922.rusty@rustcorp.com.au>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, maxk@qualcomm.com
To: rusty@rustcorp.com.au (Rusty Russell)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755846AbYDGFOE@vger.kernel.org>
In-Reply-To: <200804052206.33922.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell <rusty@rustcorp.com.au> wrote:
>
> +/* We are done with this skb: put it in the used pile. */
> +static void skb_finished(struct skb_shared_info *sinfo)
> +{
> +       struct skb_shinfo_tun *sht = (void *)(sinfo + 1);
> +
> +       /* FIXME: Race prevention */
> +       vring_used_buffer_atomic(sht->tun->outring, sht->id, sht->len);
> +       vring_wake(sht->tun->outring);
> +
> +       /* Release device. */
> +       dev_put(sht->tun->dev);
> +}

On second thought, this is not going to work.  The network stack
can clone individual pages out of this skb and put it into a new
skb.  Therefore whatever scheme we come up with will either need
to be page-based, or add a flag to tell the network stack that it
can't clone those pages.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
