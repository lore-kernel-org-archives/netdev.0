From: "Hugo Santos" <hugosantos@gmail.com>
Subject: Re: [GIT PULL] IPv6 Updates
Date: Wed, 14 Feb 2007 22:38:15 +0000
Message-ID: <9c46321e0702141438l58d3eb2aoe74576d70019ea54@mail.gmail.com>
References: <E1HHRCL-00028w-00@gondolin.me.apana.org.au>
	 <E1HHRj7-0002HG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hasso@estpak.ee, yoshfuji@linux-ipv6.org, davem@davemloft.net,
	netdev@vger.kernel.org, aramoto@linux-ipv6.org,
	kozakai@linux-ipv6.org
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:5549 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932663AbXBNWiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 17:38:17 -0500
Received: by ug-out-1314.google.com with SMTP id 44so370167uga
        for <netdev@vger.kernel.org>; Wed, 14 Feb 2007 14:38:15 -0800 (PST)
In-Reply-To: <E1HHRj7-0002HG-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  Thank you all for these changes.

  Hugo

On 2/14/07, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> >
> > [IPV4] devinet: Register inetdev earlier.
>
> I needed to move the panic call as well.
>
> [IPV4] devinet: Register inetdev earlier.
>
> This patch allocates inetdev at registration for all devices
> in line with IPv6.  This allows sysctl configuration on the
> devices to occur before they're brought up or addresses are
> added.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index ba5e7f4..2224f8e 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1055,12 +1055,14 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
>         ASSERT_RTNL();
>
>         if (!in_dev) {
> -               if (event == NETDEV_REGISTER && dev == &loopback_dev) {
> +               if (event == NETDEV_REGISTER) {
>                         in_dev = inetdev_init(dev);
> -                       if (!in_dev)
> -                               panic("devinet: Failed to create loopback\n");
> -                       in_dev->cnf.no_xfrm = 1;
> -                       in_dev->cnf.no_policy = 1;
> +                       if (dev == &loopback_dev) {
> +                               if (!in_dev)
> +                                       panic("devinet: Failed to create loopback\n");
> +                               in_dev->cnf.no_xfrm = 1;
> +                               in_dev->cnf.no_policy = 1;
> +                       }
>                 }
>                 goto out;
>         }
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
