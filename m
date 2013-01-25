From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 2/2] v2 GRE: Add segmentation offload for GRE
Date: Fri, 25 Jan 2013 02:14:47 +0100
Message-ID: <CAHXqBFLLdTO0cf1+sT96teh4AuHzbxygHQsbJ_8Vec6giYVNTw@mail.gmail.com>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jesse@nicira.com, eric.dumazet@gmail.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:48170 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065Ab3AYBPI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 20:15:08 -0500
Received: by mail-oa0-f53.google.com with SMTP id l20so2898105oag.40
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 17:15:08 -0800 (PST)
In-Reply-To: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/24 Pravin B Shelar <pshelar@nicira.com>:
[...]
> @@ -1374,6 +1421,10 @@ static int ipgre_tunnel_init(struct net_device=
 *dev)
>                 return err;
>         }
>
> +       if (!(tunnel->parms.o_flags & GRE_SEQ)) {
> +               dev->features |=3D NETIF_F_GSO_SOFTWARE;
> +               dev->hw_features |=3D NETIF_F_GSO_SOFTWARE;
> +       }
>         return 0;
>  }
>

Can o_flags change after tunnel creation? If so, NETIF_F_GSO_SOFTWARE
should be set in dev->hw_features always, and it should be forced zero
in ndo_fix_features when GRE_SEQ is set. ipgre_netlink_parms() should
call netdev_update_features() when o_flags changes.

> @@ -1564,6 +1615,10 @@ static int ipgre_tap_init(struct net_device *d=
ev)
>         if (!dev->tstats)
>                 return -ENOMEM;
>
> +       if (!(tunnel->parms.o_flags & GRE_SEQ)) {
> +               dev->features |=3D NETIF_F_GSO_SOFTWARE;
> +               dev->hw_features |=3D NETIF_F_GSO_SOFTWARE;
> +       }
>         return 0;
>  }
>

Same here.

Best Regards,
Micha=B3 Miros=B3aw
