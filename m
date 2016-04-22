From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/6] Documentation: Binding doc for ethernet master in NS2
Date: Fri, 22 Apr 2016 15:13:51 -0500
Message-ID: <20160422201351.GA3048@rob-hp-laptop>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <1461230323-27891-6-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
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
In-Reply-To: <1461230323-27891-6-git-send-email-pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 21, 2016 at 02:48:42PM +0530, Pramod Kumar wrote:
> Adding binding doc for ethernet master present in shared
> MDIO controller.
> 
> Signed-off-by: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Reviewed-by: Ray Jui <ray.jui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Reviewed-by: Scott Branden <scott.branden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
>  .../bindings/net/brcm,iproc-mdio-shared.txt        | 32 ++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt b/Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
> new file mode 100644
> index 0000000..1ffdd4b
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
> @@ -0,0 +1,32 @@
> +Broadcom Ethernet master for shared mdio controller
> +
> +Required properties:
> +- compatible: must be "brcm,iproc-mdio-master-eth"
> +- reg: master id of Ethernet block
> +- address-cells: should be 1
> +- size-cells: should be 0
> +
> +Sub-nodes:
> +  Each port's PHY should be represented as a sub-node.
> +
> +Sub-nodes required properties:
> +- reg: the PHY number
> +- phy-mode: media type connecting the PHY and MAC.
> +
> +
> +Example:
> +	eth-master@0 {

Is this a child of something?

Why is this not just an mdio bus underneath the ethernet controller? How 
is this accessed?

> +		compatible = "brcm,iproc-mdio-master-eth";
> +		reg = <0x0>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		gphy0: eth-phy@10 {
> +			reg = <0x10>;
> +			phy-mode = "mii";
> +		};
> +		status = "ok"
> +	};
> +
> +For more info on ethernet phy binding, please,refer to:
> +Documentation/devicetree/bindings/net/phy.txt
> +Documentation/devicetree/bindings/net/ethernet.txt
> -- 
> 1.9.1
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
