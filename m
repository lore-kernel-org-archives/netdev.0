From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [RFC Patch net-next 4/5] sunrpc: use generic union inet_addr
Date: Thu, 27 Jun 2013 16:37:57 +0100
Message-ID: <1372347477.2436.7.camel@bwh-desktop.uk.level5networks.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-5-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	<linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Cong Wang <amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372315398-19683-5-git-send-email-amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
[...]
> --- a/include/net/inet_addr.h
> +++ b/include/net/inet_addr.h
> @@ -60,6 +60,62 @@ static inline bool inet_addr_multicast(const union inet_addr *ipa)
>  }
>  #endif
>  
> +/**
> + * inet_addr_copy - copy the address portion of one sockaddr to another
> + * @dst: destination sockaddr
> + * @src: source sockaddr
> + *
> + * Just copies the address portion and family. Ignores port, scope, etc.
> + * Caller is responsible for making certain that dst is large enough to hold
> + * the address in src. Returns true if address family is supported. Returns
> + * false otherwise.
> + */
> +static inline bool inet_addr_copy(union inet_addr *dst,
> +				  const union inet_addr *src)
> +{
> +	dst->sa.sa_family = src->sa.sa_family;
> +
> +	switch (src->sa.sa_family) {
> +	case AF_INET:
> +		dst->sin.sin_addr.s_addr = src->sin.sin_addr.s_addr;
> +		return true;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	case AF_INET6:
> +		dst->sin6.sin6_addr = src->sin6.sin6_addr;
> +		dst->sin6.sin6_scope_id = src->sin6.sin6_scope_id;
> +		return true;
> +#endif

Most of the other functions work on IPv6 addresses without CONFIG_IPV6;
why should this be different?

Ben.

> +	}
> +
> +	return false;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
