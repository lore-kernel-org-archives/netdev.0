From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch this
Date: Fri, 27 Sep 2002 05:00:30 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209270100.FAA19447@sex.inr.ac.ru>
References: <3D893ECC.4020906@candelatech.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.COM (Ben Greear)
In-Reply-To: <3D893ECC.4020906@candelatech.com> from "Ben Greear" at Sep 19, 2 07:15:01 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> The old way is broken, it sets the bound-device to 0 when sending
> the syn-ack.

Ben, this function is _not_ used to send syn-acks...


> +#ifdef CONFIG_NET_SENDTOSELF
> +	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(skb->nh.iph->tos), sk->bound_dev_if))
> +#else
>   	if (ip_route_output(&rt, daddr, rt->rt_spec_dst, RT_TOS(skb->nh.iph->tos), 0))
> +#endif

This chunk is noop, sk here is a dummy socket internal to kernel,
where sk->bound_dev_if is identical zero. Grep code to see
what it is used for.

The same ("noopness") is true about 90% of the patch. F.e. all the messing
inside tcp with openreqs is noop.

Essentially, the only chunk which has a real meaning is that one
for fib_frontend.c. And it is simpler to do this with sysctl, compare
to rp_filter at al.

Alexey
