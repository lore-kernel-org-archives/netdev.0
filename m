From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] netfilter: ipset: Null pointer exception in ipset
 list:set
Date: Thu, 16 Feb 2017 20:58:15 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1702162057140.8526@blackhole.kfki.hu>
References: <1487198726-21866-1-git-send-email-vpai@akamai.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>, johunt@akamai.com,
        pai.vishwain@gmail.com, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org
To: Vishwanath Pai <vpai@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1487198726-21866-1-git-send-email-vpai@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 15 Feb 2017, Vishwanath Pai wrote:

> If we use before/after to add an element to an empty list it will cause
> a kernel panic.
> 
> $> cat crash.restore
> create a hash:ip
> create b hash:ip
> create test list:set timeout 5 size 4
> add test b before a
> 
> $> ipset -R < crash.restore
> 
> Executing the above will crash the kernel.
> 
> Signed-off-by: Vishwanath Pai <vpai@akamai.com>
> Reviewed-by: Josh Hunt <johunt@akamai.com>
> ---
>  net/netfilter/ipset/ip_set_list_set.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
> index 51077c5..178d4eb 100644
> --- a/net/netfilter/ipset/ip_set_list_set.c
> +++ b/net/netfilter/ipset/ip_set_list_set.c
> @@ -260,11 +260,14 @@ struct list_set {
>  		else
>  			prev = e;
>  	}
> +
> +	/* If before/after is used on an empty set */
> +	if ((d->before > 0 && !next) ||
> +	    (d->before < 0 && !prev))
> +		return -IPSET_ERR_REF_EXIST;
> +
>  	/* Re-add already existing element */
>  	if (n) {
> -		if ((d->before > 0 && !next) ||
> -		    (d->before < 0 && !prev))
> -			return -IPSET_ERR_REF_EXIST;
>  		if (!flag_exist)
>  			return -IPSET_ERR_EXIST;
>  		/* Update extensions */
> -- 
> 1.9.1

Patch is applied, thank you!

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
