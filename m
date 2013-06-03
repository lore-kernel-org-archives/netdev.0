From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -next] net: sun4i-emac: fix a typo in emac_probe()
Date: Mon, 03 Jun 2013 09:20:49 -0700
Message-ID: <1370276449.2025.33.camel@joe-AO722>
References: <CAPgLHd-fXnt9H_CxDD1Ww=C-6nn3COVkYirKY6ucOJVR2Pkwkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	maxime.ripard@free-electrons.com, davem@davemloft.net, sr@denx.de,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38306 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758614Ab3FCQUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 12:20:52 -0400
In-Reply-To: <CAPgLHd-fXnt9H_CxDD1Ww=C-6nn3COVkYirKY6ucOJVR2Pkwkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 21:36 +0800, Wei Yongjun wrote:
> Just fixed a typo in emac_probe().

also fixed a memory leak.

> diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
[]
> @@ -821,7 +821,7 @@ static int emac_probe(struct platform_device *pdev)
>  	db->membase = of_iomap(np, 0);
>  	if (!db->membase) {
>  		dev_err(&pdev->dev, "failed to remap registers\n");
> -		return -ENOMEM;
> +		ret = -ENOMEM;
>  		goto out;
>  	}

out:
	dev_err(db->dev, "not found (%d).\n", ret);

	free_netdev(ndev);
