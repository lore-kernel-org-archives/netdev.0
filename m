From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net IPv6]: Fix maximum IPv6 address limit violation
Date: Mon, 07 Apr 2014 15:06:11 -0400 (EDT)
Message-ID: <20140407.150611.1998010372710875030.davem@davemloft.net>
References: <533FEE9B.5090806@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: kumaran.4353@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533FEE9B.5090806@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Sat, 05 Apr 2014 17:22:59 +0530

> +#ifdef CONFIG_IPV6_PRIVACY
> +           /* When IPv6 privacy extension is enabled, there must
> +            * be two IPv6 address slots available.
> +            * - One for MAC based address
> +            * - Another for temporary address
> +            */
> +           if (max_addresses > 1)
> +               max_addresses--;
> +#endif
>             if (!max_addresses ||
>                 ipv6_count_addresses(in6_dev) < max_addresses)
>                 ifp = ipv6_add_addr(in6_dev, &addr, NULL,
> -- 
> 1.7.9.5
> 

Your claim is that you're shooting for accurate policy enforcement, but even
you patch doesn't do this.

You are not taking into account whether temporary addresses will even be
created.

An accurate implementation would duplicate all of the special checks that
manage_tempaddrs() does to determine whether a temporary address will be
created or not.  In particular, it needs to check if the device is even
configured to use tempaddrs.
