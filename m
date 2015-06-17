From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next 43/43] netfilter: Skip unnecessary calls to
 synchronize_net
Date: Wed, 17 Jun 2015 19:20:54 +0200
Message-ID: <20150617172054.GJ13215@acer.localdomain>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
 <1434554932-4552-43-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35895 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756646AbbFQRU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 13:20:58 -0400
Content-Disposition: inline
In-Reply-To: <1434554932-4552-43-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.06, Eric W. Biederman wrote:
> From: Eric W Biederman <ebiederm@xmission.com>
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/netfilter/core.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 95456c09cf69..1b4eadc9c030 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -134,7 +134,9 @@ void nf_unregister_hook(struct net *net, const struct nf_hook_ops *reg)
>  #ifdef HAVE_JUMP_LABEL
>  	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
>  #endif
> -	synchronize_net();
> +	/* Don't wait if there are no packets in flight */
> +	if (net->loopback_dev)
> +		synchronize_net();

I don't get this, could you please explain why there wouldn't be any packets
in flight if there is no loopback_dev?

>  	kfree(elem);
>  }
>  EXPORT_SYMBOL(nf_unregister_hook);
> -- 
> 2.2.1
> 
