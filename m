From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 10:05:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930000515.GA10496@gondor.apana.org.au>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu> <415B24C0.2020208@us.ibm.com> <20040929145050.71afa1ac.davem@davemloft.net> <20040929215613.GC26714@wotan.suse.de> <20040929162923.796d142e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, niv@us.ibm.com, jheffner@psc.edu,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040929162923.796d142e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 04:29:23PM -0700, David S. Miller wrote:
>
> @@ -567,12 +567,18 @@
>  	}
>  
>  	skb->ip_summed = CHECKSUM_HW;
> +
> +	/* Any change of skb->len requires recalculation of tso
> +	 * factor and mss.
> +	 */
> +	tcp_set_skb_tso_factor(skb, tp->mss_cache_std);

Minor optimsations: __tcp_trim_head is only called directly when
tso_factor has already been adjusted by tcp_tso_acked.  So you can
move this setting into tcp_trim_head.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
