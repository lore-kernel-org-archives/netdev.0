From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPsec and Path MTU
Date: Thu, 17 Jun 2004 10:58:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617105843.314dfe30.davem@redhat.com>
References: <20040616202341.GD29781@ms2.inr.ac.ru>
	<E1BajZO-0001UK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, herbert@gondor.apana.org.au, jmorris@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1BajZO-0001UK-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jun 2004 09:11:50 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This is what prompted me to look at this two months ago.  The stack
> assumes that the MTU for an xfrm dst is equal to
> 
> 	dst_pmtu(dst) - dst->header_len - dst->trailer_len
> 
> But this is not true for ESP due to block padding.  The trailer_len
> is variable and the one we store in trailer_len is not the maximum.
> 
> There are two approaches to this problem.  We can either store the
> maximum trailer_len, or make dst_pmtu(dst) return the correct MTU
> directly.
> 
> The former is simple to do, but has the disadvantage of wasting
> bandwidth up to a block.  The latter looks non-trivial, but is
> pretty simple once we solve the following problems.

Do you see what xfrm_get_mss() does?  It calls into x->type->get_max_size()
and this is where ESP reports this kind of thing (re: block padding).
