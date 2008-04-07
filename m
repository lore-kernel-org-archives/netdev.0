From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC 4/5] tun: vringfd xmit support.
Date: Mon, 7 Apr 2008 17:24:51 +1000
Message-ID: <200804071724.51781.rusty@rustcorp.com.au>
References: <E1Jijfs-0004Lo-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, maxk@qualcomm.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36720 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbYDGHZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 03:25:17 -0400
In-Reply-To: <E1Jijfs-0004Lo-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 07 April 2008 15:13:44 Herbert Xu wrote:
> Rusty Russell <rusty@rustcorp.com.au> wrote:
> > +/* We are done with this skb: put it in the used pile. */
> > +static void skb_finished(struct skb_shared_info *sinfo)
> > +{
> > +       struct skb_shinfo_tun *sht = (void *)(sinfo + 1);
> > +
> > +       /* FIXME: Race prevention */
> > +       vring_used_buffer_atomic(sht->tun->outring, sht->id, sht->len);
> > +       vring_wake(sht->tun->outring);
> > +
> > +       /* Release device. */
> > +       dev_put(sht->tun->dev);
> > +}
>
> On second thought, this is not going to work.  The network stack
> can clone individual pages out of this skb and put it into a new
> skb.  Therefore whatever scheme we come up with will either need
> to be page-based, or add a flag to tell the network stack that it
> can't clone those pages.

Erk... I'll put in the latter for now.   A page-level solution is not really 
an option: if userspace hands us mmaped pages for example.

Thanks,
Rusty.
