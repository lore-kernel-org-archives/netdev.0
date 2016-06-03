From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: RE: [PATCH v2 3/7] binding: mdio-mux: Add DT binding doc for Broadcom
 MDIO bus mutiplexer
Date: Fri, 3 Jun 2016 20:20:52 +0530
Message-ID: <a18d8d629426ccbca1a9da19241a6e5d@mail.gmail.com>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
 <1464701801-17243-4-git-send-email-pramod.kumar@broadcom.com> <20160603014323.GA12365@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:34875 "EHLO
	mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbcFCOuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 10:50:55 -0400
Received: by mail-it0-f53.google.com with SMTP id z189so138393420itg.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 07:50:55 -0700 (PDT)
In-Reply-To: <20160603014323.GA12365@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,

> -----Original Message-----
> From: Rob Herring [mailto:robh@kernel.org]
> Sent: 03 June 2016 07:13
> To: Pramod Kumar
> Cc: Pawel Moll; Mark Rutland; Ian Campbell; Kumar Gala; Catalin Marinas;
Will
> Deacon; Kishon Vijay Abraham I; David S. Miller;
devicetree@vger.kernel.org;
> linux-arm-kernel@lists.infradead.org; bcm-kernel-feedback-
> list@broadcom.com; linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [PATCH v2 3/7] binding: mdio-mux: Add DT binding doc for
> Broadcom MDIO bus mutiplexer
>
> On Tue, May 31, 2016 at 07:06:37PM +0530, Pramod Kumar wrote:
> > Add DT binding doc for Broadcom MDIO bus mutiplexer driver.
> >
> > Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> > ---
> >  .../bindings/net/brcm,mdio-mux-iproc.txt           | 60
> ++++++++++++++++++++++
> >  1 file changed, 60 insertions(+)
> >  create mode 100644
> > Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> >
> > diff --git
> > a/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> > b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> > new file mode 100644
> > index 0000000..f270b41
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/brcm,mdio-mux-iproc.txt
> > @@ -0,0 +1,60 @@
> > +Properties for an MDIO bus mutiplexer found in Broadcom iProc based
SoCs.
> > +
> > +This MDIO bus multiplexer defines buses that could be internal as
> > +well as external to SoCs and could accept MDIO transaction compatible
> > +to C-22 or
> > +C-45 Clause. When Child bus is selected, one need to select these two
>
> s/Child/child/

Sure. Will ensure this.

> s/need/needs/

Sure. Will ensure this.

> > +properties as well to generate desired MDIO trascation on appropriate
bus.
> > +
> > +Required properties in addition to the generic multiplexer
properties:
> > +
> > +MDIO multiplexer node:
> > +- complatible: brcm,mdio-mux-iproc.
>
> typo
>
Fixed.
> > +
> > +Every non-ethernet PHY requires a compatible so that it could be
> > +probed based on this compatible string.
> > +
> > +Additional information regarding generic multiplexer properties could
> > +be found
>
> s/could/can/
>

Replaced.

> > +at- Documentation/devicetree/bindings/net/mdio-mux.txt
> > +
> > +
> > +for example:
> > +		mdio_mux_iproc: mdio_mux_iproc@6602023c {
>
> No '_' in node names.
>
> mdio-mux@...

Yes. Will take care of this.
>
> > +			compatible = "brcm,mdio-mux-iproc";
> > +			reg = <0x6602023c 0x14>;
> > +			#address-cells = <1>;
> > +			#size-cells = <0>;
> > +			mdio-integrated-mux;
> > +
> > +			mdio@0 {
> > +				reg = <0x0>;
> > +				#address-cells = <1>;
> > +				#size-cells = <0>;
> > +
> > +				pci_phy0: pci-phy@0 {
> > +					compatible = "brcm,ns2-pcie-phy";
> > +					reg = <0x0>;
> > +					#phy-cells = <0>;
> > +				};
> > +			};
> > +
> > +			mdio@7 {
> > +				reg = <0x7>;
> > +				#address-cells = <1>;
> > +				#size-cells = <0>;
> > +
> > +				pci_phy1: pci-phy@0 {
> > +					compatible = "brcm,ns2-pcie-phy";
> > +					reg = <0x0>;
> > +					#phy-cells = <0>;
> > +				};
> > +			};
> > +			mdio@10 {
> > +				reg = <0x10>;
> > +				#address-cells = <1>;
> > +				#size-cells = <0>;
> > +
> > +				gphy0: eth-phy@10 {
> > +					reg = <0x10>;
> > +				};
> > +			};
> > +		};
> > --
> > 1.9.1
> >

Regards,
Pramod
