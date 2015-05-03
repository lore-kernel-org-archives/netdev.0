From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: fix dependency issues between IPv6
 defragmentation and ip6tables
Date: Sun, 3 May 2015 13:07:15 +0200
Message-ID: <20150503110715.GE22481@breakpoint.cc>
References: <1430646618-7625-1-git-send-email-sdu.liu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kadlec@blackhole.kfki.hu, kaber@trash.net,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	liusdu@126.com
To: Liu Hua <sdu.liu@huawei.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1430646618-7625-1-git-send-email-sdu.liu@huawei.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Liu Hua <sdu.liu@huawei.com> wrote:
> commit f6318e558806c925029dc101f14874be9f9fa78f fix some related issue
> when ip6tables is enabled. But when IP6_NF_IPTABLES is disabled and
> NETFILTER_XT_TARGET_TPROXY is enabled. We will meet build failure with
> "net/built-in.o: In function `tproxy_tg_init':
> net/netfilter/xt_TPROXY.c:588: undefined reference to `nf_defrag_ipv6_enable'
> "
> So this patch change the Kconfig as ipv4 does.
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -865,7 +865,7 @@ config NETFILTER_XT_TARGET_TPROXY
>  	depends on (IPV6 || IPV6=n)
>  	depends on IP_NF_MANGLE
>  	select NF_DEFRAG_IPV4
> -	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
> +	select NF_DEFRAG_IPV6

If IP6_NF_IPTABLES is not set, why would we have to pick
up IPV6 defragmentation?

Without ip6tables, TPROXY cannot be used for ipv6; in fact;
xt_TPROXY should be built without ipv6 support in this case.

My guess is that you have TPROXY=y but DEFRAG_IPV6=m, but that
might warrant a better fix (xt_socket seems to have same issue).
