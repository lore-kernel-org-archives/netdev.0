From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Frequent Oops on Shutdown 2.6.10
Date: Wed, 23 Feb 2005 20:51:44 +1100
Message-ID: <20050223095144.GB16820@gondor.apana.org.au>
References: <20050221.162949.65179228.yoshfuji@linux-ipv6.org> <E1D3Wn9-00071h-00@gondolin.me.apana.org.au> <20050222101526.GA5814@gondor.apana.org.au> <20050223.183555.80618945.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: AndyLiebman@aol.com, terryg@axian.com, netdev@oss.sgi.com,
        davem@davemloft.net, akpm@osdl.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050223.183555.80618945.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Feb 23, 2005 at 06:35:55PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> What do you think of this?

Thanks, this looks great.  There is just one technical detail
to patch up.
 
> -int snmp6_unregister_dev(struct inet6_dev *idev)
> +int snmp6_free_dev(struct inet6_dev *idev)
>  {
>  	snmp6_mib_free((void **)idev->stats.icmpv6);
>  	return 0;
>  }

You need to check whether icmpv6[0] is NULL either here or in
snmp6_mib_free.  Otherwise when snmp6_alloc_dev fails we'll
wind up here and then call free_percpu on a pair of NULL pointers.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
