From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETDEV: fix receiving multicast frames.
Date: Wed, 25 May 2005 18:19:14 +1000
Message-ID: <E1Dar6g-0002R8-00@gondolin.me.apana.org.au>
References: <20050525.160704.28910448.yoshfuji@linux-ipv6.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20050525.160704.28910448.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Some USB ethernet drivers did not accept multicast frames appropriately.
> IPv6 did not work with those drivers without this patch.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Index: drivers/usb/net/pegasus.c
> ===================================================================
> --- 5b713315560487f8c288820b17061fe27016c2cc/drivers/usb/net/pegasus.c  (mode:100644)
> +++ uncommitted/drivers/usb/net/pegasus.c  (mode:100644)
> @@ -1166,7 +1166,7 @@
>                pegasus->eth_regs[EthCtrl2] |= RX_PROMISCUOUS;
>                if (netif_msg_link(pegasus))
>                        pr_info("%s: Promiscuous mode enabled.\n", net->name);
> -       } else if ((net->mc_count > multicast_filter_limit) ||
> +       } else if (net->mc_count ||
>                   (net->flags & IFF_ALLMULTI)) {
>                pegasus->eth_regs[EthCtrl0] |= RX_MULTICAST;
>                pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
> Index: drivers/usb/net/rtl8150.c
> ===================================================================
> --- 5b713315560487f8c288820b17061fe27016c2cc/drivers/usb/net/rtl8150.c  (mode:100644)
> +++ uncommitted/drivers/usb/net/rtl8150.c  (mode:100644)
> @@ -667,7 +667,7 @@
>        if (netdev->flags & IFF_PROMISC) {
>                dev->rx_creg |= cpu_to_le16(0x0001);
>                info("%s: promiscuous mode", netdev->name);
> -       } else if ((netdev->mc_count > multicast_filter_limit) ||
> +       } else if (netdev->mc_count ||
>                   (netdev->flags & IFF_ALLMULTI)) {
>                dev->rx_creg &= cpu_to_le16(0xfffe);
>                dev->rx_creg |= cpu_to_le16(0x0002);

This patch is correct.  However, I presume these chips do actually have
filter support so it'd be even better if we could utilise that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
