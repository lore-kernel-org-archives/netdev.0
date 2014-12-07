From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Fix build for NETFILTER_XT_TARGET_REDIRECT
Date: Sun, 7 Dec 2014 19:23:13 +0100
Message-ID: <20141207182313.GA4243@salvia>
References: <1417858919-10576-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org,
	Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417858919-10576-1-git-send-email-linux@roeck-us.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 06, 2014 at 01:41:59AM -0800, Guenter Roeck wrote:
> Fix:
> 
> ERROR: "nf_nat_redirect_ipv6" [net/netfilter/xt_REDIRECT.ko] undefined!
> 
> Seen if NETFILTER_XT_TARGET_REDIRECT is configured but NF_NAT_IPV6
> is not, since code compiled with NF_NAT_REDIRECT_IPV6 is used
> unconditionally by code enabled with NETFILTER_XT_TARGET_REDIRECT.
> This means that NETFILTER_XT_TARGET_REDIRECT depends on NF_NAT_IPV6
> and must always select NF_NAT_REDIRECT_IPV6.

Thanks for your patch. However, we decided to resolve this by
combining nf_reject_ipv4 and nf_reject_ipv6.

See b59eaf9 ("netfilter: combine IPv4 and IPv6 nf_nat_redirect code in one
module").

Let us know if you still hit problems after that patch. Thanks.
