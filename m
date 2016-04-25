From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH 2/6] Documentation: DT binding doc for iProc Shared MDIO
 Controller.
Date: Mon, 25 Apr 2016 17:33:36 +0200
Message-ID: <20160425153336.GK6575@lunn.ch>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <1461230323-27891-3-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	BCM Kernel Feedback <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Suzuki K Poulose <suzuki.poulose-5wv7dgnIgG8@public.gmane.org>,
	Punit Agrawal <punit.agrawal-5wv7dgnIgG8@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1461230323-27891-3-git-send-email-pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +Example:
> +iproc_mdio: iproc_mdio@663f0000 {
> +	compatible = "brcm,iproc-shared-mdio";
> +	reg = <0x6602023c 0x14>;
> +	reg-names = "mdio";
> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +
> +	sata-master@6 {
> +		compatible = "brcm,iproc-ns2-sata-phy";
> +		reg = <0x6>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		brcm,phy-internal;
> +
> +		sata_phy0: sata-phy@1 {
> +			reg = <0x1>;
> +			#phy-cells = <0>;
> +		};
> +
> +		sata_phy1: sata-phy@2 {
> +			reg = <0x2>;
> +			#phy-cells = <0>;
> +		};
> +	};
> +
> +	eth-master@0 {
> +		compatible = "brcm,iproc-mdio-master-eth";
> +		reg = <0x0>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		gphy0: eth-phy@10 {
> +			reg = <0x10>;
> +			phy-mode = "mii";
> +		};
> +	};
> +};

So looking at this, you have an MDIO bus, an MDIO mux on top of that,
and then some MDIO devices on the muxed busses. You don't need a whole
new framework for this. You need a new mdio-mux driver, but the
existing MDIO framework should do what you need.

	 Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
