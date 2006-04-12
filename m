From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] atm: clip causes unregister hang
Date: Thu, 13 Apr 2006 04:08:20 +1000
Message-ID: <E1FTjlM-00050V-00@gondolin.me.apana.org.au>
References: <20060412105545.3b089dd8@localhost.localdomain>
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:23565 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932303AbWDLSIi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 14:08:38 -0400
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20060412105545.3b089dd8@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen:

Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> --- linux-2.6.16.2.orig/net/atm/clip.c  2006-04-12 10:10:43.000000000 -0700
> +++ linux-2.6.16.2/net/atm/clip.c       2006-04-12 10:15:46.000000000 -0700
> @@ -613,12 +613,19 @@
> 
> 
> static int clip_device_event(struct notifier_block *this,unsigned long event,
> -    void *dev)
> +                            void *arg)
> {
> +       struct net_device *dev = arg;
> +
> +       if (event == NETDEV_DOWN) {
> +               neigh_ifdown(&clip_tbl, dev);
> +               return NOTIFY_DONE;
> +       }

You want NETDEV_UNREGISTER because neigh entries may get added
even if the device is down.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
