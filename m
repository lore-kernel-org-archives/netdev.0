From: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH 2/6] Documentation: DT binding doc for iProc Shared MDIO Controller.
Date: Mon, 25 Apr 2016 09:57:32 +0530
Message-ID: <c943aae3b7a5d9600cd329520a19eb0f@mail.gmail.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <1461230323-27891-3-git-send-email-pramod.kumar@broadcom.com> <20160422201045.GA32303@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
	Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Suzuki K Poulose <suzuki.poulose-5wv7dgnIgG8@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Punit Agrawal <punit.agrawal-5wv7dgnIgG8@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	BCM Kernel Feedback <bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160422201045.GA32303@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,

Thanks for reviewing and providing your valuable comments.

> -----Original Message-----
> From: Rob Herring [mailto:robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org]
> Sent: 23 April 2016 01:41
> To: Pramod Kumar
> Cc: Catalin Marinas; Will Deacon; Masahiro Yamada; Chen-Yu Tsai; Mark
> Rutland; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Pawel Moll; Arnd Bergmann; Suzuki K
> Poulose; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Punit Agrawal;
linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> BCM Kernel Feedback; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> Subject: Re: [PATCH 2/6] Documentation: DT binding doc for iProc Shared
MDIO
> Controller.
>
> On Thu, Apr 21, 2016 at 02:48:39PM +0530, Pramod Kumar wrote:
> > Add DT binding doc for iProc Shared MDIO Controller which populate all
> > masters to Shared MDIO framework.
> >
> > Signed-off-by: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> > Reviewed-by: Ray Jui <ray.jui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> > Reviewed-by: Scott Branden <scott.branden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> > ---
> >  .../bindings/bus/brcm,iproc-shared-mdio.txt        | 76
> ++++++++++++++++++++++
> >  1 file changed, 76 insertions(+)
> >  create mode 100644
> > Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
> >
> > diff --git
> > a/Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
> > b/Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
> > new file mode 100644
> > index 0000000..f455f3d
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/bus/brcm,iproc-shared-mdio.txt
> > @@ -0,0 +1,76 @@
> > +Broadcom iProc Shared MDIO Controller
> > +
> > +Required properties:
> > +- compatible:
> > +    "brcm,iproc-shared-mdio" for shared MDIO controller.
> > +- reg: specifies the base physical address and size of the registers
> > +- reg-names: should be "mdio"
> > +- #address-cells: must be 1.
> > +- #size-cells: must be 0.
> > +
> > +optional:
> > +child nodes: Masters are represented as a child node of shared MDIO
> > +controller and all the PHYs handled by this master are represented as
its child
> node.
>
> Seems kind of useless if child nodes are optional.
>

I agree. I'll put it under required properties.

> > +
> > +Master nodes properties are defined as-
> > +
> > +Required properties:
> > +- compatible: Used to match driver of this PHY.
> > +- reg: MDIO master ID.
> > +- #address-cells: must be 1.
> > +- #size-cells: must be 0.
> > +
> > +optional:
> > +-brcm,phy-internal: if presents, PHYs are internal. Absence shows phy
> > +is external.
> > +-brcm,is-c45: if presents, Controller uses Clause-45 to issue MDIO
> transaction.
> > +else Controller uses Clause-22 for transactions.
>
> Isn't this a property of the phy? IIRC, there is a standard property or
compatible
> string for this.
>

Shared MDIO controller's master holds all above property to ensure the
proper MDIO transaction over its bus.  Hence tried to pinned here.
These properties are standard one for the Ethernet PHY but Broadcom SoCs
MDIO is shared even with other I/O subsystem. Other subsystem does not
defines this property hence has been defined here.

> > +
> > +PHY nodes are represented as the child node of Master. Child nodes
> > +properties are defined as-
> > +
> > +Required properties:
> > +-reg: phy id of attached PHY.
> > +
> > +optional:
> > +There could be additional properties required to configure the
> > +specific phy like phy-mode in case of gpphy node below. These should
> > +be defined here and used by respective drivers.
> > +
> > +Example:
> > +iproc_mdio: iproc_mdio@663f0000 {
> > +	compatible = "brcm,iproc-shared-mdio";
> > +	reg = <0x6602023c 0x14>;
> > +	reg-names = "mdio";
> > +	#address-cells = <1>;
> > +	#size-cells = <0>;
> > +
> > +	sata-master@6 {
>
> mdio@6

Do you advise us to rename the node name as mdio@6? If yes, I don't have
any personal preferences here and would do it. I'd thought to give proper
name so that consumer could get what this node is representing.
Please suggest us.

>
> > +		compatible = "brcm,iproc-ns2-sata-phy";
> > +		reg = <0x6>;
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +		brcm,phy-internal;
> > +
> > +		sata_phy0: sata-phy@1 {
>
> phy@1
>

Same as above.

> > +			reg = <0x1>;
> > +			#phy-cells = <0>;
> > +		};
> > +
> > +		sata_phy1: sata-phy@2 {
>
> phy@2
>

Same as above.

> > +			reg = <0x2>;
> > +			#phy-cells = <0>;
> > +		};
> > +	};
> > +
> > +	eth-master@0 {
>
> mdio@0

Same as above.
>
> > +		compatible = "brcm,iproc-mdio-master-eth";
> > +		reg = <0x0>;
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +		gphy0: eth-phy@10 {
>
> phy@10
>

Same as above.
> > +			reg = <0x10>;
> > +			phy-mode = "mii";
> > +		};
> > +	};
> > +};
> > --
> > 1.9.1
> >
> >
> > _______________________________________________
> > linux-arm-kernel mailing list
> > linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> > http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

Regards,
Pramod
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
