From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] fou: add Kconfig options for IPv6 support
Date: Sun, 29 May 2016 22:24:48 -0700 (PDT)
Message-ID: <20160529.222448.2275780335073525850.davem@davemloft.net>
References: <1464187873-219087-1-git-send-email-arnd@arndb.de>
	<1464187873-219087-2-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464187873-219087-2-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 25 May 2016 16:50:46 +0200

> A previous patch added the fou6.ko module, but that failed to link
> in a couple of configurations:
> 
> net/built-in.o: In function `ip6_tnl_encap_add_fou_ops':
> net/ipv6/fou6.c:88: undefined reference to `ip6_tnl_encap_add_ops'
> net/ipv6/fou6.c:94: undefined reference to `ip6_tnl_encap_add_ops'
> net/ipv6/fou6.c:97: undefined reference to `ip6_tnl_encap_del_ops'
> net/built-in.o: In function `ip6_tnl_encap_del_fou_ops':
> net/ipv6/fou6.c:106: undefined reference to `ip6_tnl_encap_del_ops'
> net/ipv6/fou6.c:107: undefined reference to `ip6_tnl_encap_del_ops'
> 
> If CONFIG_IPV6=m, ip6_tnl_encap_add_ops/ip6_tnl_encap_del_ops
> are in a module, but fou6.c can still be built-in, and that
> obviously fails to link.
> 
> Also, if CONFIG_IPV6=y, but CONFIG_IPV6_TUNNEL=m or
> CONFIG_IPV6_TUNNEL=n, the same problem happens for a different
> reason.
> 
> This adds two new silent Kconfig symbols to work around both
> problems:
> 
> - CONFIG_IPV6_FOU is now always set to 'm' if either CONFIG_NET_FOU=m
>   or CONFIG_IPV6=m
> - CONFIG_IPV6_FOU_TUNNEL is set implicitly when IPV6_FOU is enabled
>   and NET_FOU_IP_TUNNELS is also turned out, and it will ensure
>   that CONFIG_IPV6_TUNNEL is also available.
> 
> The options could be made user-visible as well, to give additional
> room for configuration, but it seems easier not to bother users
> with more choice here.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: aa3463d65e7b ("fou: Add encap ops for IPv6 tunnels")

Applied.
