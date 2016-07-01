From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [RFC PATCH 0/2] net: ethernet: Add support for gmii2rgmii
 converter
Date: Fri, 1 Jul 2016 15:29:59 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5BAC07@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1467354012-7364-1-git-send-email-appanad@xilinx.com>
 <20160701151304.GE6804@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Michal Simek <michals@xilinx.com>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Harini Katakam <harinik@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160701151304.GE6804@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> On Fri, Jul 01, 2016 at 11:50:10AM +0530, Kedareswara rao Appana wrote:
> > This patch series does the following
> > ---> Add support for gmii2rgmii converter.
> 
> How generic is this gmii2rgmii IP block? Could it be used with any GMII and
> RGMII device?

This converter does GMII2RGMII conversion.
This can be used with any MAC which has shared MDIO with external PHY
And this Converter. This Converter IP is validated for MACB.
But it should work with any MAC which has shared MDIO bus (I mean single MDIO multiple PHYS)...

This converter works like below

MACB <==> GMII2RGMII <==> RGMII_PHY

	MDIO	    <========> GMII2RGMII
MCAB<=======> 
		  <========> RGMII

Using MACB MDIO bus we can access both the converter and the external PHY.
We need to program the line speed of the converter during run time based on the External phy negotiated speed. 

MDIO interface is used to set operating speed (line speed) 

The converter has only one register (0x10) that we need to program to set the operating speed.
The composition of this register is similar to the IEEE standard 802.3 MDIO control register 0x0.

Please let me know if you still not clear about how this converter works.

> 
> Should it be placed in drivers/net/phy, so making it easier to reuse?

Ok will move it drivers/net/phy folder in the next version...

> 
> Also, Russell Kings phylink might be a more natural structure for this. It is hard to
> know when those patches will land, but it might be worth looking at.

Ok sure will take a look at this series once posted...

Regards,
Kedar.

> 
>        Andrew
