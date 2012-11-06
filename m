From: "Bedia, Vaibhav" <vaibhav.bedia@ti.com>
Subject: RE: [PATCH 3/7] ARM: OMAP3+: hwmod: Add AM33XX HWMOD data for
 davinci_mdio module
Date: Tue, 6 Nov 2012 10:09:08 +0000
Message-ID: <B5906170F1614E41A8A28DE3B8D121433EC049CC@DBDE01.ent.ti.com>
References: <1352189545-26303-1-git-send-email-mugunthanvnm@ti.com>
 <1352189545-26303-4-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Richard Cochran <richardcochran@gmail.com>,
	Paul Walmsley <paul@pwsan.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"Hiremath, Vaibhav" <hvaibhav@ti.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:59066 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234Ab2KFKJW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 05:09:22 -0500
In-Reply-To: <1352189545-26303-4-git-send-email-mugunthanvnm@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 06, 2012 at 13:42:21, N, Mugunthan V wrote:
[...]
> +struct omap_hwmod_addr_space am33xx_mdio_addr_space[] = {
> +	{
> +		.pa_start	= 0x4A101000,
> +		.pa_end		= 0x4A101000 + SZ_256 - 1,
> +		.flags		= ADDR_MAP_ON_INIT,

Based on the recent discussions and looking the hwmod code,
I guess ADDR_MAP_ON_INIT does not make sense here. Since you
are just creating a parent-child relationship here, maybe no
flag is needed? 

> +	},
> +	{ }
> +};
> +
> +struct omap_hwmod_ocp_if am33xx_cpgmac0__mdio = {
> +	.master		= &am33xx_cpgmac0_hwmod,
> +	.slave		= &am33xx_mdio_hwmod,
> +	.addr		= am33xx_mdio_addr_space,
> +	.user		= OCP_USER_MPU,

Is this flag necessary? Shouldn't you just skip the
user field since there's nothing for the hwmod code
to do here?

Regards,
Vaibhav
