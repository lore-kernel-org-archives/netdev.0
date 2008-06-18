From: "Matvejchikov Ilya" <matvejchikov@gmail.com>
Subject: Re: [PATCH] fs_enet: restore promiscuous and multicast settings in restart()
Date: Wed, 18 Jun 2008 22:45:57 +0400
Message-ID: <8496f91a0806181145w62d57a7fua767c8036f2261aa@mail.gmail.com>
References: <200806181707.17739.laurentp@cse-semaphore.com>
Reply-To: matvejchikov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	pantelis.antoniou@gmail.com, vbordug@ru.mvista.com
To: "Laurent Pinchart" <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:39144 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806AbYFRSp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 14:45:58 -0400
Received: by yx-out-2324.google.com with SMTP id 31so70509yxl.1
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 11:45:57 -0700 (PDT)
In-Reply-To: <200806181707.17739.laurentp@cse-semaphore.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm glad that you have corrected it. Half a year ago I pointed out
that there was such a mistake:
http://patchwork.ozlabs.org/linuxppc/patch?id=10700

Thanks.

2008/6/18 Laurent Pinchart <laurentp@cse-semaphore.com>:
> The restart() function is called when the link state changes and resets
> multicast and promiscous settings. This patch restores those settings at the
> end of restart().
>
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> ---
>  drivers/net/fs_enet/mac-fcc.c     |    3 +++
>  2 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
> index ce40cf9..1a95cf1 100644
> --- a/drivers/net/fs_enet/mac-fcc.c
> +++ b/drivers/net/fs_enet/mac-fcc.c
> @@ -464,6 +464,9 @@ static void restart(struct net_device *dev)
>                C32(fccp, fcc_fpsmr, FCC_PSMR_FDE | FCC_PSMR_LPB);
>
>        S32(fccp, fcc_gfmr, FCC_GFMR_ENR | FCC_GFMR_ENT);
> +
> +       /* Restore multicast and promiscous settings */
> +       set_multicast_list(dev);
>  }
>
>  static void stop(struct net_device *dev)
> --
> 1.5.0
>
> --
> Laurent Pinchart
> CSE Semaphore Belgium
>
> Chaussee de Bruxelles, 732A
> B-1410 Waterloo
> Belgium
>
> T +32 (2) 387 42 59
> F +32 (2) 387 42 75
>
