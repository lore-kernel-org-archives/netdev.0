From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Mon, 14 Jun 2004 09:35:53 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <E1BZeW1-0008Ny-00@gondolin.me.apana.org.au>
References: <20040613121514.6b3c1c8a.davem@redhat.com>
Cc: schwab@suse.de, linux-net@vger.kernel.org, netdev@oss.sgi.com,
	yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20040613121514.6b3c1c8a.davem@redhat.com>
List-Id: netdev.vger.kernel.org

David S. Miller <davem@redhat.com> wrote:
>
> diff -Nru a/net/core/dst.c b/net/core/dst.c
> --- a/net/core/dst.c    2004-06-13 06:04:49 -07:00
> +++ b/net/core/dst.c    2004-06-13 06:04:49 -07:00
> @@ -230,8 +230,8 @@
>                                if (event!=NETDEV_DOWN &&
>                                    dst->output == dst_discard_out) {

This is a historical question.  What's the dst->output check for?

>                                        dst->dev = &loopback_dev;
> -                                       dev_put(dev);
>                                        dev_hold(&loopback_dev);
> +                                       dev_put(dev);
>                                        dst->output = dst_discard_out;
>                                        if (dst->neighbour && dst->neighbour->dev == dev) {
>                                                dst->neighbour->dev = &loopback_dev;
> @@ -242,6 +242,8 @@
>                                        dst->input = dst_discard_in;
>                                        dst->output = dst_discard_out;
>                                }

The loopback_dev stuff takes care of the case when someone is still
holding onto the dst.  How come we don't have similar code in ifdown?

> +                               if (dst->ops->ifdown)
> +                                       dst->ops->ifdown(dst, event != NETDEV_DOWN);

What's the rationale for doing this for both UNREGISTER and DOWN?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
