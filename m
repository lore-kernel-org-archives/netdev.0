From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCHv2 net-next] net: fec: Ensure clocks are enabled while
 using mdio bus
Date: Sat, 20 Jun 2015 14:47:20 -0300
Message-ID: <CAOMZO5Bb2i2Xr2-+6pNSy5WHxh1FK3utB3-VqS6X-_OK=+t82g@mail.gmail.com>
References: <1434816914-9816-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Duan Andy <fugang.duan@freescale.com>,
	Cory Tusar <cory.tusar@pid1solutions.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:36119 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604AbbFTRrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 13:47:22 -0400
Received: by lbbqq2 with SMTP id qq2so88068266lbb.3
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2015 10:47:20 -0700 (PDT)
In-Reply-To: <1434816914-9816-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 20, 2015 at 1:15 PM, Andrew Lunn <andrew@lunn.ch> wrote:

> @@ -1764,6 +1765,11 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
>  {
>         struct fec_enet_private *fep = bus->priv;
>         unsigned long time_left;
> +       int ret;
> +
> +       ret = clk_prepare_enable(fep->clk_ipg);
> +       if (ret)
> +               return 0xffff;

Why don`t you return ret instead?
