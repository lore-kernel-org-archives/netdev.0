From: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH 5/6] Documentation: Binding doc for ethernet master in NS2
Date: Mon, 25 Apr 2016 10:13:16 +0530
Message-ID: <9d799bfef311ca7ec5d4c3953f615140@mail.gmail.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
 <1461230323-27891-6-git-send-email-pramod.kumar@broadcom.com> <20160422201351.GA3048@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160422201351.GA3048@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Rob,

Thanks for review and providing your valuable comments.

> -----Original Message-----
> From: Rob Herring [mailto:robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org]
> Sent: 23 April 2016 01:44
> To: Pramod Kumar
> Cc: Catalin Marinas; Will Deacon; Masahiro Yamada; Chen-Yu Tsai; BCM
Kernel
> Feedback; Pawel Moll; Mark Rutland; Arnd Bergmann; Suzuki K Poulose;
Punit
> Agrawal; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org;
> linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH 5/6] Documentation: Binding doc for ethernet master
in
> NS2
>
> On Thu, Apr 21, 2016 at 02:48:42PM +0530, Pramod Kumar wrote:
> > Adding binding doc for ethernet master present in shared MDIO
> > controller.
> >
> > Signed-off-by: Pramod Kumar <pramod.kumar-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> > Reviewed-by: Ray Jui <ray.jui-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> > Reviewed-by: Scott Branden <scott.branden-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> > ---
> >  .../bindings/net/brcm,iproc-mdio-shared.txt        | 32
> ++++++++++++++++++++++
> >  1 file changed, 32 insertions(+)
> >  create mode 100644
> > Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
> >
> > diff --git
> > a/Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
> > b/Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
> > new file mode 100644
> > index 0000000..1ffdd4b
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
> > @@ -0,0 +1,32 @@
> > +Broadcom Ethernet master for shared mdio controller
> > +
> > +Required properties:
> > +- compatible: must be "brcm,iproc-mdio-master-eth"
> > +- reg: master id of Ethernet block
> > +- address-cells: should be 1
> > +- size-cells: should be 0
> > +
> > +Sub-nodes:
> > +  Each port's PHY should be represented as a sub-node.
> > +
> > +Sub-nodes required properties:
> > +- reg: the PHY number
> > +- phy-mode: media type connecting the PHY and MAC.
> > +
> > +
> > +Example:
> > +	eth-master@0 {
>
> Is this a child of something?
>

This is an Shared MDIO master node as described in cover letter and is the
child node of iProc_shared_mdio plarform driver.


> Why is this not just an mdio bus underneath the ethernet controller? How
is this
> accessed?

This is the part for Shared MDIO controller which is shared among other
subsystem as well hence defined here. This works as glue layer between
This controller and legacy MDIO framework and register the MDIO bus to
legacy framework.
When any read/write request is issue from Legacy MDIO controller framework
it gets propagated to Shared controller platform driver via this driver
and finally platform driver issue MDIO transaction over bus.

>
> > +		compatible = "brcm,iproc-mdio-master-eth";
> > +		reg = <0x0>;
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +		gphy0: eth-phy@10 {
> > +			reg = <0x10>;
> > +			phy-mode = "mii";
> > +		};
> > +		status = "ok"
> > +	};
> > +
> > +For more info on ethernet phy binding, please,refer to:
> > +Documentation/devicetree/bindings/net/phy.txt
> > +Documentation/devicetree/bindings/net/ethernet.txt
> > --
> > 1.9.1
> >

Regards,
Pramod
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
