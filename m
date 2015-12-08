From: David Miller <davem@davemloft.net>
Subject: Re: netlink: Add missing goto statement to netlink_insert
Date: Tue, 08 Dec 2015 11:21:48 -0500 (EST)
Message-ID: <20151208.112148.848925272627144797.davem@davemloft.net>
References: <20151207012042.GA7420@gondor.apana.org.au>
	<56652E11.4010604@profihost.ag>
	<20151208061319.GA16209@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: s.priebe@profihost.ag, hannes@stressinduktion.org,
	fweimer@redhat.com, tglx@linutronix.de, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	j.winkel@profihost.ag, m.schinkel@profihost.ag,
	stable@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151208061319.GA16209@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 8 Dec 2015 14:13:19 +0800

> On Mon, Dec 07, 2015 at 07:58:25AM +0100, Stefan Priebe - Profihost AG wrote:
>>
>> Thanks, good. Can you help me to get this fix upstream into the stable
>> lines?
> 
> Sure.  Greg, please apply this patch to fix up the backport for 4.1.

Herbert, thanks so much for taking care of this.

> ---8<---
> The backport of 1f770c0a09da855a2b51af6d19de97fb955eca85 ("netlink:
> Fix autobind race condition that leads to zero port ID") missed a
> goto statement, which causes netlink to break subtly.
> 
> This was discovered by Stefan Priebe <s.priebe@profihost.ag>.
> 
> Fixes: 4e2776241766 ("netlink: Fix autobind race condition that...")
> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Reported-by: Philipp Hahn <pmhahn@pmhahn.de>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: David S. Miller <davem@davemloft.net>

> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index d139c43..0d6038c 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1118,6 +1118,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
>  		if (err == -EEXIST)
>  			err = -EADDRINUSE;
>  		sock_put(sk);
> +		goto err;
>  	}
>  
>  	/* We need to ensure that the socket is hashed and visible. */
> 
> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
