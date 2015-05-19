From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 for-next 04/12] IB/ipoib: Return IPoIB devices
 matching connection parameters
Date: Tue, 19 May 2015 12:28:10 -0600
Message-ID: <20150519182810.GG18675@obsidianresearch.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1431841868-28063-5-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1431841868-28063-5-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 17, 2015 at 08:51:00AM +0300, Haggai Eran wrote:

> +#if IS_ENABLED(CONFIG_IPV6)
> +	struct sockaddr_in6 *addr_in6 = (struct sockaddr_in6 *)addr;
> +#endif
> +	__be32 ret_addr;
> +
> +	switch (addr->sa_family) {
> +	case AF_INET:
> +		in_dev = in_dev_get(dev);
> +		if (!in_dev)
> +			return false;
> +
> +		ret_addr = inet_confirm_addr(net, in_dev, 0,
> +					     addr_in->sin_addr.s_addr,
> +					     RT_SCOPE_HOST);
> +		in_dev_put(in_dev);
> +		if (ret_addr)
> +			return true;
> +
> +		break;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	case AF_INET6:
> +		if (ipv6_chk_addr(net, &addr_in6->sin6_addr, dev, 1))
> +			return true;
> +
> +		break;
> +#endif

Can you use

  if (IS_ENABLED(CONFIG_IPV6))

At the call site instead of the #if guards?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
