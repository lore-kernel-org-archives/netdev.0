From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [RFC Patch net-next 4/5] sunrpc: use generic union inet_addr
Date: Thu, 27 Jun 2013 16:36:53 +0100
Message-ID: <1372347413.2436.6.camel@bwh-desktop.uk.level5networks.com>
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
> -/**
> - * rpc_cmp_addr - compare the address portion of two sockaddrs.
> - * @sap1: first sockaddr
> - * @sap2: second sockaddr
> - *
> - * Just compares the family and address portion. Ignores port, but
> - * compares the scope if it's a link-local address.

You're removing the scope comparison.

Ben.

> - * Returns true if the addrs are equal, false if they aren't.
> - */
>  static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
>  				const struct sockaddr *sap2)
>  {
> -	if (sap1->sa_family == sap2->sa_family) {
> -		switch (sap1->sa_family) {
> -		case AF_INET:
> -			return __rpc_cmp_addr4(sap1, sap2);
> -		case AF_INET6:
> -			return __rpc_cmp_addr6(sap1, sap2);
> -		}
> -	}
> -	return false;
> +	return inet_addr_equal((const union inet_addr *)sap1,
> +			       (const union inet_addr *)sap2);
>  }
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
