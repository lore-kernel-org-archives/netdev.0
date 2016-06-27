From: Carlo Caione <carlo@caione.org>
Subject: Re: [PATCH RFC 3/3] ARM64: dts: meson-gxbb: use the new meson8b
 DWMAC glue
Date: Mon, 27 Jun 2016 11:24:48 +0200
Message-ID: <20160627092448.GA3275@localhost>
References: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
 <20160625165013.15917-4-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-amlogic@lists.infradead.org, mark.rutland@arm.com,
	khilman@baylibre.com, robh+dt@kernel.org, netdev@vger.kernel.org,
	peppe.cavallaro@st.com
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32890 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbcF0JYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 05:24:51 -0400
Received: by mail-wm0-f66.google.com with SMTP id r201so22931540wme.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 02:24:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160625165013.15917-4-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/06/16 18:50, Martin Blumenstingl wrote:
> The Amlogic reference driver uses the "mc_val" devicetree property to
> configure the PRG_ETHERNET_ADDR0 register. Unfortunately it uses magic
> values for this configuration.
> 
> According to the datasheet the PRG_ETHERNET_ADDR0 register is at address
> 0xc8834108. However, the reference driver uses 0xc8834540 instead.
> According to my tests, the value from the reference driver is correct.
> 
> The updated examples are representing 0x1621 from the reference driver's
> mc_val property, which is used when there is an external gbit PHY
> connected.
> For RMII mode PHYs mc_val 0x1800 is used in the reference driver, which
> translates  would translate to "do not set any of the following
> properties" (as the two bits are configured automatically):
> - amlogic,enable-25mhz-phy-clk
> - amlogic,mp2-clock
> - amlogic,tx-delay

[...]

>  			};
> +
> +			prg_ethernet: prg_ethernet@540 {
> +				compatible = "syscon";
> +				reg = <0x0 0x00540 0x0 0x8>;
> +			};
>  		};


A syscon is a region containing a set of miscellaneous registers used
for several reasons by several devices [1]. It this case there is really
no need to define a new syscon node since those two registers are only
used by your driver.

[1] http://lxr.free-electrons.com/source/Documentation/devicetree/bindings/mfd/syscon.txt

>  		hiubus: hiubus@c883c000 {
> @@ -354,14 +360,14 @@
>  		};
>  
>  		ethmac: ethernet@c9410000 {
> -			compatible = "amlogic,meson6-dwmac", "snps,dwmac";
> -			reg = <0x0 0xc9410000 0x0 0x10000
> -			       0x0 0xc8834540 0x0 0x4>;
> +			compatible = "amlogic,meson8b-dwmac", "snps,dwmac";
> +			reg = <0x0 0xc9410000 0x0 0x10000>;
>  			interrupts = <0 8 1>;
>  			interrupt-names = "macirq";
>  			clocks = <&clkc CLKID_ETH>;
>  			clock-names = "stmmaceth";
>  			phy-mode = "rgmii";
> +			amlogic,prg-ethernet = <&prg_ethernet>;
>  			status = "disabled";
>  		};
>  	};
> -- 
> 2.9.0
> 
> 
> _______________________________________________
> linux-amlogic mailing list
> linux-amlogic@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-amlogic

-- 
Carlo Caione
