From: Etienne Basset <etienne.basset@numericable.fr>
Subject: Re: [PATCH] netlabel: Always remove the correct address selector
Date: Wed, 22 Apr 2009 07:55:05 +0200
Message-ID: <49EEB139.2050309@numericable.fr>
References: <20090421200422.10106.24767.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421200422.10106.24767.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Paul Moore wrote:
> The NetLabel address selector mechanism has a problem where it can get
> mistakenly remove the wrong selector when similar addresses are used.  The
> problem is caused when multiple addresses are configured that have different
> netmasks but the same address, e.g. 127.0.0.0/8 and 127.0.0.0/24.  This patch
> fixes the problem.

thanks Paul!

Tested-by: Etienne Basset <etienne.basset@numericable.fr>

> 
> Reported-by: Etienne Basset <etienne.basset@numericable.fr>
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> ---
> 
>  net/netlabel/netlabel_addrlist.c |   26 ++++++++++----------------
>  1 files changed, 10 insertions(+), 16 deletions(-)
> 
> diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
> index 834c6eb..c051913 100644
> --- a/net/netlabel/netlabel_addrlist.c
> +++ b/net/netlabel/netlabel_addrlist.c
> @@ -256,13 +256,11 @@ struct netlbl_af4list *netlbl_af4list_remove(__be32 addr, __be32 mask,
>  {
>  	struct netlbl_af4list *entry;
>  
> -	entry = netlbl_af4list_search(addr, head);
> -	if (entry != NULL && entry->addr == addr && entry->mask == mask) {
> -		netlbl_af4list_remove_entry(entry);
> -		return entry;
> -	}
> -
> -	return NULL;
> +	entry = netlbl_af4list_search_exact(addr, mask, head);
> +	if (entry == NULL)
> +		return NULL;
> +	netlbl_af4list_remove_entry(entry);
> +	return entry;
>  }
>  
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> @@ -299,15 +297,11 @@ struct netlbl_af6list *netlbl_af6list_remove(const struct in6_addr *addr,
>  {
>  	struct netlbl_af6list *entry;
>  
> -	entry = netlbl_af6list_search(addr, head);
> -	if (entry != NULL &&
> -	    ipv6_addr_equal(&entry->addr, addr) &&
> -	    ipv6_addr_equal(&entry->mask, mask)) {
> -		netlbl_af6list_remove_entry(entry);
> -		return entry;
> -	}
> -
> -	return NULL;
> +	entry = netlbl_af6list_search_exact(addr, mask, head);
> +	if (entry == NULL)
> +		return NULL;
> +	netlbl_af6list_remove_entry(entry);
> +	return entry;
>  }
>  #endif /* IPv6 */
>  
> 
> 

