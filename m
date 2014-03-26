From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCHv2] net: mvneta: use devm_ioremap_resource() instead of
 of_iomap()
Date: Wed, 26 Mar 2014 05:42:11 -0300
Message-ID: <20140326084211.GA941@arch.cereza>
References: <1395822600-30469-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:51595 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751330AbaCZImd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 04:42:33 -0400
Content-Disposition: inline
In-Reply-To: <1395822600-30469-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Mar 26, Thomas Petazzoni wrote:
> @@ -2838,9 +2840,10 @@ static int mvneta_probe(struct platform_device=
 *pdev)
> =20
>  	clk_prepare_enable(pp->clk);
> =20
> -	pp->base =3D of_iomap(dn, 0);
> +	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	pp->base =3D devm_ioremap_resource(&pdev->dev, res);
>  	if (pp->base =3D=3D NULL) {

As per the comment above devm_ioremap_resource() definition, the usage =
is:

	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
	base =3D devm_ioremap_resource(&pdev->dev, res);
	if (IS_ERR(base))
		return PTR_ERR(base);

--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
