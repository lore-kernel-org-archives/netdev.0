From: Simon Baatz <gmbnomis@gmail.com>
Subject: Re: [PATCH 3/5 v2] ARM: kirkwood: add device node entries for the
 gigabit interfaces
Date: Thu, 4 Apr 2013 23:35:17 +0200
Message-ID: <20130404213517.GB25904@schnuecks.de>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1365071235-11611-4-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
	moinejf@free.fr, jason@lakedaemon.net, andrew@lunn.ch,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	rob.herring@calxeda.com, grant.likely@secretlab.ca,
	jogo@openwrt.org, buytenh@wantstofly.org, jm@lentin.co.uk,
	linux-arm-kernel@lists.infradead.org,
	sebastian.hesselbarth@gmail.com
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:47219 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764844Ab3DDVfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 17:35:21 -0400
Received: by mail-bk0-f41.google.com with SMTP id i18so1799568bkv.0
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 14:35:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1365071235-11611-4-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Thu, Apr 04, 2013 at 12:27:13PM +0200, Florian Fainelli wrote:
> This patch modifies kirkwood.dtsi to specify the various gigabit
> interfaces nodes available on kirkwood devices. They are disabled by
> default and should be enabled on a per-board basis. egiga0 and egiga1
> aliases are defined for convenience. The mdio node is also present and
> should be enabled on a per-board basis as well.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---
> Changes since v1:
> - dropped change to arch/arm/mach-kirkwood/common.c to avoid merge conflicts

I think we should remove the clock aliases in
kirkwood_legacy_clk_init() in mach-kirkwood/dt-board.c (once we have
proper clock support, see my other mail).

> - fixed off-by 0x2000 ethernet-group nodes address
> 
>  arch/arm/boot/dts/kirkwood.dtsi |   46 +++++++++++++++++++++++++++++++++++++++
>  1 file changed, 46 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/kirkwood.dtsi b/arch/arm/boot/dts/kirkwood.dtsi
> index fada7e6..254f5a8 100644
> --- a/arch/arm/boot/dts/kirkwood.dtsi
> +++ b/arch/arm/boot/dts/kirkwood.dtsi
> @@ -7,6 +7,8 @@
>  	aliases {
>  	       gpio0 = &gpio0;
>  	       gpio1 = &gpio1;
> +	       egiga0 = &egiga0;
> +	       egiga1 = &egiga1;
>  	};
>  	intc: interrupt-controller {
>  		compatible = "marvell,orion-intc", "marvell,intc";
> @@ -202,5 +204,49 @@
>  			clocks = <&gate_clk 4>;
>  			status = "disabled";
>  		};
> +
> +		mdio@72004 {
> +			#address-cells = <1>;
> +			#size-cells = <0>;
> +			compatible = "marvell,orion-mdio";
> +			reg = <0x72004 0x84>;

Don't we need to add:

			interrupts = <46>;

here?


- Simon
