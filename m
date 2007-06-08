From: "Miles Lane" <miles.lane@gmail.com>
Subject: Re: 2.6.22-rc4-mm2 -- ipw2200 -- SIOCSIFADDR: No buffer space available
Date: Thu, 7 Jun 2007 23:35:17 -0700
Message-ID: <a44ae5cd0706072335w6244f267x1fb0158dd536085c@mail.gmail.com>
References: <a44ae5cd0706071125p2079472eme52821bd134d26b0@mail.gmail.com>
	 <20070607131559.cd95a181.akpm@linux-foundation.org>
	 <20070607222015.GA14966@atjola.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "=?ISO-8859-1?Q?Bj=F6rn_Steinbrink?=" <B.Steinbrink@gmx.de>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Miles Lane" <miles.lane@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:21131 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756975AbXFHGfS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 02:35:18 -0400
Received: by wa-out-1112.google.com with SMTP id v27so916541wah
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 23:35:18 -0700 (PDT)
In-Reply-To: <20070607222015.GA14966@atjola.homenet>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/7/07, Bj=F6rn Steinbrink <B.Steinbrink@gmx.de> wrote:
[...]
> Miles, could you try if this patch helps?
>
> Bj=F6rn
>
>
> Stop destroying devices when all of their ifas are gone, as we no lon=
ger
> recreate them when ifas are added.
>
> Signed-off-by: Bj=F6rn Steinbrink <B.Steinbrink@gmx.de>
> --
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index fa97b96..abf6352 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -327,12 +327,8 @@ static void __inet_del_ifa(struct in_device *in_=
dev, struct in_ifaddr **ifap,
>                 }
>
>         }
> -       if (destroy) {
> +       if (destroy)
>                 inet_free_ifa(ifa1);
> -
> -               if (!in_dev->ifa_list)
> -                       inetdev_destroy(in_dev);
> -       }
>  }
>
>  static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr =
**ifap,
>

Bj=F6rn,

Thanks.  You patch worked for me.

             Miles
