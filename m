From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 1/4] ethernet: arc: Add support for Rockchip SoC layer device tree bindings
Date: Wed, 03 Sep 2014 13:14:54 +0200
Message-ID: <3774938.44qiV4hEoE@wuerfel>
References: <1409740036-8117-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Romain Perier <romain.perier@gmail.com>, heiko@sntech.de,
	linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:56121 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755593AbaICLPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 07:15:04 -0400
In-Reply-To: <1409740036-8117-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 03 September 2014 10:27:13 Romain Perier wrote:
> +static const struct emac_rockchip_soc_data emac_rockchip_dt_data[] = {
> +       { .grf_offset = 0x154 }, /* rk3066 */
> +       { .grf_offset = 0x0a4 }, /* rk3188 */
> +};
> +
> +static const struct of_device_id emac_rockchip_dt_ids[] = {
> +       { .compatible = "rockchip,rk3066-emac", .data = &emac_rockchip_dt_data[0] },
> +       { .compatible = "rockchip,rk3188-emac", .data = &emac_rockchip_dt_data[1] },
> +       { /* Sentinel */ }
> +};
> +
> 

One last question: is this the location given as .grf_offset the
only thing in grf that is potentially of concern to this driver?

If it is, you can change the binding to include the register number
in the syscon reference, like

	rockchip,grf = <&grf 0x154>;

and then read it from there, to simplify the code needed to get the
number from the device id.

	Arnd
