From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH net-next 10/10] net: mvneta: Use the new hwbm framework
Date: Tue, 12 Jan 2016 23:40:40 +0100
Message-ID: <CAPv3WKcKK8fS-6koSgV7ABi8bvkRgzaqJDpOETCpGoTc2sWV=w@mail.gmail.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
	<1452625834-22166-11-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36294 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbcALWkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 17:40:41 -0500
Received: by mail-ob0-f174.google.com with SMTP id ba1so449444058obb.3
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 14:40:40 -0800 (PST)
In-Reply-To: <1452625834-22166-11-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gregory,

A quick remark below. All changes look fine to me at a first look, but
I will test and dig more into code soon.

>
> @@ -3946,11 +3965,6 @@ static int mvneta_probe(struct platform_device *pdev)
>         dev->priv_flags |= IFF_UNICAST_FLT;
>         dev->gso_max_segs = MVNETA_MAX_TSO_SEGS;
>
> -       err = register_netdev(dev);
> -       if (err < 0) {
> -               dev_err(&pdev->dev, "failed to register\n");
> -               goto err_free_stats;
> -       }

The purpose of shifting register_netdev() was to be able to obtain
pp->id from net_device, before mvneta_bm_port_init is called. It is
needed for proper port - pool mapping control.

>
>         pp->id = dev->ifindex;
>
> @@ -3965,6 +3979,12 @@ static int mvneta_probe(struct platform_device *pdev)
>                 }
>         }
>
> +       err = register_netdev(dev);
> +       if (err < 0) {
> +               dev_err(&pdev->dev, "failed to register\n");
> +               goto err_free_stats;
> +       }
> +
>         err = mvneta_init(&pdev->dev, pp);
>         if (err < 0)
>                 goto err_netdev;

Best regards,
Marcin
