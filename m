From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9-rc1-mm5: TCP oopses
Date: Mon, 13 Sep 2004 21:53:35 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040913215335.64508d55.davem@davemloft.net>
References: <20040913190858.12544431.davem@davemloft.net>
	<E1C745E-00024r-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268904AbUINEzp@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C745E-00024r-00@gondolin.me.apana.org.au>
List-Id: netdev.vger.kernel.org

On Tue, 14 Sep 2004 13:34:20 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > @@ -968,11 +972,17 @@
> >                return -EAGAIN;
> > 
> >        if (skb->len > cur_mss) {
> > +               int old_factor = TCP_SKB_CB(skb)->tso_factor;
> > +               int new_factor;
> > +
> >                if (tcp_fragment(sk, skb, cur_mss))
> >                        return -ENOMEM; /* We'll try again later. */
> > 
> >                /* New SKB created, account for it. */
> > -               tcp_inc_pcount(&tp->packets_out, skb);
> > +               new_factor = TCP_SKB_CB(skb)->tso_factor;
> > +               tcp_dec_pcount_explicit(&tp->packets_out,
> > +                                       new_factor - old_factor);
> 
> That should be tcp_inc_pcount_explicit.

Better fix is to transpose the factors in the subtraction.
That's what I was trying to do here.

Good eyes Herbert.
