From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [RFC PATCH v2 2/4] net: ethernet: xilinx: Add gmii2rgmii
 converter support
Date: Mon, 4 Jul 2016 12:36:05 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5BB285@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
 <1467623084-15471-3-git-send-email-appanad@xilinx.com>
 <577A323A.4080207@atmel.com>
 <C246CAC1457055469EF09E3A7AC4E11A4A5BB227@XAP-PVEXMBX01.xlnx.xilinx.com>
 <577A572F.1050004@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"Michal Simek" <michals@xilinx.com>,
	Soren Brinkmann <sorenb@xilinx.com>,
	"Punnaiah Choudary Kalluri" <punnaia@xilinx.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Harini Katakam <harinik@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0074.outbound.protection.outlook.com ([104.47.36.74]:34127
	"EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753644AbcGDMgM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 08:36:12 -0400
In-Reply-To: <577A572F.1050004@atmel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,


> >
> > #ifdef CONFIG_NET_VENDOR_XILINX
> 
> You may need to have:
> #if defined(CONFIG_NET_VENDOR_XILINX) &&
> defined(CONFIG_XILINX_GMII2RGMII)
> 
> >  extern int gmii2rgmii_phyprobe(struct gmii2rgmii *xphy); #else extern
> > void gmii2rgmii_phyprobe(struct gmii2rgmii *xphy);
> 
> No need for the line above...
> 
> > void gmii2rgmii_phyprobe(struct gmii2rgmii *xphy) { }
> 
> On one single line, like:
> 
> static inline void gmii2rgmii_phyprobe(struct gmii2rgmii *xphy) { }
> 
> > #endif
> > For me the changes are looking odd...
> 
> For me, it's okay...

Ok will fix as you suggested...

> 
> >
> > Other possible ways
> > 	1)  Put a config check around phyprobe api in the macb driver.
> > #ifdef CONFIG_XILINX_GMII2RGMII
> >                        gmii2rgmii_phyprobe(&bp->converter_phy);
> > #endif
> 
> Nope!
> 
> > 	2) Select NET_VENDOR_XILINX in the macb Kconfig @ -22,6 +22,7 @@
> > config MACB
> >         tristate "Cadence MACB/GEM support"
> >         depends on HAS_DMA
> >         select PHYLIB
> > +       select NET_VENDOR_XILINX
> 
> 
> 
> > Please let me know which one you prefer will fix that and will post v3...
> 
> First one with my changes is the best. But maybe wait for more feedback...

Ok sure will wait and will post next version with your suggestion in case of no comments...

Regards,
Kedar.

> 
> Bye,
> --
> Nicolas Ferre
