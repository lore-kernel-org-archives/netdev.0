From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: Fix build failure when ipv6 but xt_tproxy
 is built in
Date: Tue, 29 Mar 2011 22:35:36 -0700 (PDT)
Message-ID: <20110329.223536.245392030.davem@davemloft.net>
References: <1301451199.14261.327.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hidden@balabit.hu,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	kaber@trash.net, netdev@vger.kernel.org
To: rostedt@goodmis.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1301451199.14261.327.camel@gandalf.stny.rr.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 29 Mar 2011 22:13:19 -0400

> While running ktest.pl doing ranconfigs, the following build error
> occurred:

Is sending netfilter patches to the explicitly listed maintainer in
MAINTAINERS too much to ask Stephen? :-/

CC:'d

> 
> net/built-in.o: In function `tproxy_tg6_v1':
> /home/rostedt/work/autotest/nobackup/linux-test.git/net/netfilter/xt_TPROXY.c:288: undefined reference to `ipv6_find_hdr'
> 
> This happened because the xt_TPROXY code was compiled into the kernel
> proper, but the ipv6 netfilter was compiled as a module. The fix is to
> only enter the code that calls ipv6_find_hdr if ipv6 netfilter is
> compiled into the kernel, or if it is a module, so is the xt_TPROXY
> code.
> 
> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
> 
> diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
> index dcfd57e..5915f94 100644
> --- a/net/netfilter/xt_TPROXY.c
> +++ b/net/netfilter/xt_TPROXY.c
> @@ -22,7 +22,13 @@
>  
>  #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
>  
> -#if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
> +/*
> + * Only include the following if ip6 tables is compiled in
> + * the kernel, or it is a module and this code is also a module.
> + */
> +#if defined(CONFIG_IP6_NF_IPTABLES) || \
> +	(defined(CONFIG_IP6_NF_IPTABLES_MODULE) && \
> +	 defined(CONFIG_NETFILTER_XT_TARGET_TPROXY_MODULE))
>  #define XT_TPROXY_HAVE_IPV6 1
>  #include <net/if_inet6.h>
>  #include <net/addrconf.h>
> 
> 
