From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] net: sysctl for RA default route MTU
Date: Wed, 25 Mar 2015 16:52:01 +0100
Message-ID: <1427298721.2344863.245111901.25E46F85@webmail.messagingengine.com>
References: <20150324.152705.921124268458994532.davem@davemloft.net>
 <1427281679-13007-1-git-send-email-klamm@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Roman Gushchin <klamm@yandex-team.ru>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427281679-13007-1-git-send-email-klamm@yandex-team.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 25, 2015, at 12:07, Roman Gushchin wrote:
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1714,6 +1714,14 @@ int ip6_route_add(struct fib6_config *cfg)
>  
>  	rt->rt6i_flags = cfg->fc_flags;
>  
> +       if ((cfg->fc_flags & (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY))
> ==
> +           (RTF_ADDRCONF | RTF_DEFAULT | RTF_GATEWAY)) {
> +               u32 mtu = idev->cnf.ra_default_route_mtu;
> +
> +               if (mtu && mtu >= IPV6_MIN_MTU && mtu <= idev->cnf.mtu6)
> +                       dst_metric_set(&rt->dst, RTAX_MTU, mtu);
> +       }
> +

Could you move this RA specific snippet over to ndisc.c?

Hmm

How do you use this option?

You use jumbo frames on the on-link network and announce all routes via
route options where you also want to communicate to with jumbo frames?

I wonder if an offlink_mtu parameter would be more suitable?

Thanks,
Hannes
