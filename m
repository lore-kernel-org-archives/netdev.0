From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH] stmmac: Add device-tree support
Date: Wed, 14 Mar 2012 17:26:28 +0100
Message-ID: <20120314162628.GO18320@game.jcrosoft.org>
References: <1331561157-3820-1-git-send-email-sr@denx.de>
 <20120312143825.GB13869@game.jcrosoft.org>
 <4F60832E.6060100@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	devicetree-discuss@ozlabs.org, Viresh Kumar <viresh.kumar@st.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1.mo2.mail-out.ovh.net ([46.105.63.121]:47506 "EHLO
	mo2.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932180Ab2CNQib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 12:38:31 -0400
Received: from mail621.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo2.mail-out.ovh.net (Postfix) with SMTP id 3A357DC61F7
	for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 17:41:46 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <4F60832E.6060100@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12:38 Wed 14 Mar     , Giuseppe CAVALLARO wrote:
> On 3/12/2012 3:38 PM, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > On 15:05 Mon 12 Mar     , Stefan Roese wrote:
> >> This patch adds support to configure the STMMAC ethernet driver via
> >> device-tree instead of platform_data.
> >>
> >> Currently, only the properties needed on SPEAr600 are provided. All
> >> other properties should be added once needed on other platforms.
> >>
> >> Signed-off-by: Stefan Roese <sr@denx.de>
> >> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> >> Cc: Viresh Kumar <viresh.kumar@st.com>
> >> ---
> >>  Documentation/devicetree/bindings/net/stmmac.txt   |   38 +++++++++++
> >>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   66 +++++++++++++++++++-
> >>  2 files changed, 103 insertions(+), 1 deletion(-)
> >>  create mode 100644 Documentation/devicetree/bindings/net/stmmac.txt
> >>
> >> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
> >> new file mode 100644
> >> index 0000000..386a47f
> >> --- /dev/null
> >> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
> >> @@ -0,0 +1,38 @@
> >> +* STMicroelectronics 10/100/1000 Ethernet driver (GMAC)
> >> +
> >> +Required properties:
> >> +- compatible: Should be "stm,gmac"
> 
> > this IP have 2 version at least the GMAC for the second generation and mac for
> > the first generation
> 
> yes you are right. STMMAC supports two device generations I named:
> dwma10/100 and dwmac1000 (gmac).
> 
> Concerning the latter, we support several different versions of the
> synopsys GMAC cores ... from 3.30 to 3.61a.
> 
> For example, stx7108 and Stx7109 have the same GMAC core (also SPEAr600
> IIRC).
no PM the PM was only since 7108 IIRC

7109 use mac not gmac IIRC it's 7105 that start to use the GMAC with 300Mbps
max
> SPEAr13xx has 3.50a
> New ST SoC Stxh415 has the 3.60a. etc.
> 
> >> +- reg: Address and length of the register set for the device
> >> +- interrupt-parent: Should be the phandle for the interrupt controller
> >> +  that services interrupts for this device
> >> +- interrupts: Should contain the STMMAC interrupts
> >> +- interrupt-names: Should contain the interrupt names "macirq"
> >> +  "eth_wake_irq" if this interrupt is supported in the "interrupts"
> >> +  property
> > optionnal
> 
> yes
> 
> note that there will be a new field for lpi IRQ as well
> 
> >> +- phy-mode: String, operation mode of the PHY interface.
> >> +  Supported values are: "mii", "rmii", "gmii", "rgmii".
> >> +- phy-addr: MDIO address of the PHY
> >> +
> >> +Optional properties:
> >> +- stm,prog-burst-len: Specify the burst length
> >> +- stm,has-gmac: Indicates that the controller supports 1000Mbps
> > this IP support more mode 10/100/300/1000
> 
> has_gmac was used to understand on devices w/o the HW cap registers if
> the core is a gmac... another useful parameter could be : enh_desc
this need to manage via compatible

Best Regards,
J.
