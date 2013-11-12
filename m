From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6: Blackhole route support partial ?
Date: Tue, 12 Nov 2013 14:54:12 +0100
Message-ID: <20131112135412.GF14929@order.stressinduktion.org>
References: <CAP8BHkGZ5EFxW4BNervKrOiEaQTNdSh9s2YOrFoexzQCOR=AqQ@mail.gmail.com> <20131111203954.GB3043@order.stressinduktion.org> <CAP8BHkG6=KuU9K7=sGsZftMDe58eTYByRu2DZ+j+KNqcfsOfAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kamala R <kamala@aristanetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAP8BHkG6=KuU9K7=sGsZftMDe58eTYByRu2DZ+j+KNqcfsOfAA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2013 at 04:39:10PM +0530, Kamala R wrote:
> Hi,
> 
> Sure, here it is.
> 
> --- linux-3.12/net/ipv6/route.c.orig    2013-11-12 16:23:46.000000000 +0530
> +++ linux-3.12/net/ipv6/route.c 2013-11-12 16:30:51.000000000 +0530
> @@ -1570,9 +1570,13 @@ int ip6_route_add(struct fib6_config *cf
>                 switch (cfg->fc_type) {
>                 case RTN_BLACKHOLE:
>                         rt->dst.error = -EINVAL;
> +                       rt->dst.input = dst_discard;
> +                       rt->dst.discard = dst_discard;
>                         break;
>                 case RTN_PROHIBIT:
>                         rt->dst.error = -EACCES;
> +                       rt->dst.input = ip6_pkt_prohibit;
> +                       rt->dst.output = ip6_pkt_prohibit_out;
>                         break;
>                 case RTN_THROW:
>                         rt->dst.error = -EAGAIN;
> 
> Is this ok ?

I woud move all the initialization of the function pointer into the
switch-case. You could merge the case RTN_THROW with the default one by just
using a ternary statement to initialize dst.error.

Your patch must be well-formed to get included into the
kernel. For that you should base your patch ontop net-next
or net, write a proper commit message and send the git
format-patch generated patch to this list. Here some hints:
<https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/Documentation/SubmittingPatches>

You can check if your formatting is correct by using scripts/checkpatch
--strict.

Let me know if there are any problems with that.

Thank you,

  Hannes
