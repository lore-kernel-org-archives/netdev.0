From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: use devm_ioremap_resource() instead of
 of_iomap()
Date: Tue, 25 Mar 2014 20:34:24 -0300
Message-ID: <20140325233424.GA14158@arch.cereza>
References: <1395790015-20929-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:50261 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753126AbaCYXeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 19:34:46 -0400
Content-Disposition: inline
In-Reply-To: <1395790015-20929-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mar 26, Thomas Petazzoni wrote:
[..]
> @@ -2774,6 +2775,7 @@ static void mvneta_port_power_up(struct mvneta_=
port *pp, int phy_mode)
>  static int mvneta_probe(struct platform_device *pdev)
>  {
>  	const struct mbus_dram_target_info *dram_target_info;
> +	struct resource *res;
>  	struct device_node *dn =3D pdev->dev.of_node;
>  	struct device_node *phy_node;
>  	u32 phy_addr;
> @@ -2838,9 +2840,15 @@ static int mvneta_probe(struct platform_device=
 *pdev)
> =20
>  	clk_prepare_enable(pp->clk);
> =20
> -	pp->base =3D of_iomap(dn, 0);
> +	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!res) {
> +		err =3D -ENODEV;
> +		goto err_clk;
> +	}
> +
> +	pp->base =3D devm_ioremap_resource(&pdev->dev, res);

When you use devm_ioremap_resource, you don't need to have error handli=
ng
in platform_get_resource. Take a look at the comment at lib/devres.c.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
