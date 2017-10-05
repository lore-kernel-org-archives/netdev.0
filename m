From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH V2] Fix a sleep-in-atomic bug in shash_setkey_unaligned
Date: Thu, 5 Oct 2017 16:07:14 -0300
Message-ID: <20171005190713.GA4326@localhost.localdomain>
References: <20171003052643.GB22750@gondor.apana.org.au>
 <20171003224505.GE19750@localhost.localdomain>
 <20171005034054.GB31996@gondor.apana.org.au>
 <20171004.213758.2210486785503998906.davem@davemloft.net>
 <20171005101620.GA1246@gondor.apana.org.au>
 <20171005131631.GA1553@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, luto@kernel.org,
        baijiaju1990@163.com, nhorman@tuxdriver.com, vyasevich@gmail.com,
        kvalo@codeaurora.org, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171005131631.GA1553@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2017 at 09:16:31PM +0800, Herbert Xu wrote:
> On Thu, Oct 05, 2017 at 06:16:20PM +0800, Herbert Xu wrote:
> >
> > That was my point.  Functions like sctp_pack_cookie shouldn't be
> > setting the key in the first place.  The setkey should happen at
> > the point when the key is generated.  That's sctp_endpoint_init
> > which AFAICS only gets called in GFP_KERNEL context.
> > 
> > Or is there a code-path where sctp_endpoint_init is called in
> > softirq context?
> 
> OK, there are indeed code paths where the key is derived in softirq
> context.  Notably sctp_auth_calculate_hmac.
> 
> So I think this patch is the correct fix and I will push it upstream
> as well as back to stable.

Okay, thanks.

  Marcelo
