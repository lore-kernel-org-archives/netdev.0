From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv4: ip_options_compile() how can we avoid blowing up on a NULL skb???
Date: Fri, 17 Nov 2006 11:22:25 +1100
Message-ID: <E1GkrUv-00043G-00@gondolin.me.apana.org.au>
References: <9a8748490611161434oc393db0o1e1c23ba99b1c796@mail.gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1424804AbWKQAWl@vger.kernel.org>
To: jesper.juhl@gmail.com (Jesper Juhl)
In-Reply-To: <9a8748490611161434oc393db0o1e1c23ba99b1c796@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl <jesper.juhl@gmail.com> wrote:
> 
> So if 'skb' is NULL, the only route I see that doesn't cause a NULL
> pointer deref is if  (opt != NULL)  and at the same time
> (opt->is_data != NULL)  .   Is that guaranteed in any way?  If now,
> how come we don't blow up regularly?

Yes that's how it's supposed to be used.  This function either constructs
an opts structure from a packet, or it verifies the validity of a suspect
opts structure (without a packet).  In the latter case, both opt and
opt->is_data should be non-zero.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
