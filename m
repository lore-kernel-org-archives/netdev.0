From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [RFC PATCH v2 1/4] Documentation: DT: net: Add Xilinx
 gmiitorgmii converter device tree binding documentation
Date: Wed, 6 Jul 2016 16:21:21 +0200
Message-ID: <20160706142121.GI19800@lunn.ch>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
 <1467623084-15471-2-git-send-email-appanad@xilinx.com>
 <20160704140458.GC3282@lunn.ch>
 <03CA77BA8AF6F1469AEDFBDA1322A7B74A193913@XAP-PVEXMBX02.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Appana Durga Kedareswara Rao <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Soren Brinkmann <sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org" <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Anirudha Sarangi <anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <03CA77BA8AF6F1469AEDFBDA1322A7B74A193913-4lKfpRxZ5ekkx2a1wsGfbYg+Gb3gawCHQz34XiSyOiE@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > Hi Kedareswara
> > 
> > So looking at the device tree, you have the gmiitorgmii as an mdio
> > device. It will get probed as an mdio device, and from that you know
> > the address on the bus. However, your driver does not actually do
> > this. xilinx_gmii2rgmii.c is just a library of two functions, and does
> > not use any of this device tree information. You device tree binding
> > is completely bogus.
> > 
> > What i think is a much more logical structure, and fits the hardware,
> > which is what DT is all about, is to make your driver an mdio driver.
> > Also, have a phy-handle pointing to the PHY in the gmii_to_rgmii node.
> > You then no longer need the exported gmii2rgmii_phyprobe() function.
> > 
> > Next, you want gmiitorgmii driver to register a phy. The MAC driver
> > can then look this up using phy-handle:
> > 
> >        mdio {
> >                 #address-cells = <1>;
> >                 #size-cells = <0>;
> > 
> >                 phy: ethernet-phy@0 {
> >                         reg = <0>;
> >                 };
> > 
> >                 gmii_to_rgmii: gmii-to-rgmii@8 {
> >                         compatible = "xlnx,gmiitorgmii";
> >                         reg = <8>;
> > 			phy-handle = <&phy>;
> >                 };
> >        };
> 
> 
> Thanks for your inputs initially we too thought the similar implementation
> But the GMII2RGMII converter contains only one register and it is 
>  not compatible to the standard ethernet MII interface. Also it doesn't have
> a standard VID and PID registers So, during the mdio bus scan, this device will 
> not appear.

Hi Punnaiah

Use missed some subtlety in my description. I did not call the
GMII2RGMII a PHY device, i called it an MDIO device. These are
different things. Go look at the MDIO subsystem to figure out the
difference.

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
