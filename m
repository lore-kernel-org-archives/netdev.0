From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH] net: stmmac: fix stmmac_pci_probe failed when
 CONFIG_HAVE_CLK is selected
Date: Wed, 24 Sep 2014 10:48:09 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C2B7EB35E@PGSMSX102.gar.corp.intel.com>
References: <1411043650-31712-1-git-send-email-hock.leong.kweh@intel.com>
 <20140922.141921.577008114679288180.davem@davemloft.net>
 <F54AEECA5E2B9541821D670476DAE19C2B7EAE19@PGSMSX102.gar.corp.intel.com>
 <54210EC1.9070507@st.com>
 <F54AEECA5E2B9541821D670476DAE19C2B7EAF23@PGSMSX102.gar.corp.intel.com>
 <54226020.50008@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"vbridgers2013@gmail.com" <vbridgers2013@gmail.com>,
	"wens@csie.org" <wens@csie.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>,
	"tobias.johannes.klausmann@mni.thm.de"
	<tobias.johannes.klausmann@mni.thm.de>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32544 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbaIXKsP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 06:48:15 -0400
In-Reply-To: <54226020.50008@st.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Giuseppe CAVALLARO [mailto:peppe.cavallaro@st.com]
> Sent: Wednesday, September 24, 2014 2:10 PM
> >
> > Hi peppe,
> >
> > Appreciate for the explanation. Just to clarify that I am not asking not to
> pass in the priv->stmmac_clk.
> > In fact, the fix will fail at case 2 if driver cannot obtain the priv->stmmac_clk,
> but just not the case 1.
> > For case 1, seem like it does not require the stmmac_clk then I think
> > it should be OK not to fail it when driver did not get stmmac_clk but have
> the clk_csr set.
> 
> ok we can do that but this clock is also managed when the iface is down.
> Maybe it could be convenient to manage it for power consumption.
> What do you think?

Hi peppe,

I don't really get what you mean here. Are you telling that you are OK with the fix?
Or you are referring to the bottom idea which introduce clock registration APIs to
stmmac_pci driver?

Regarding the power management, isn't this taking care by the PCI framework itself
for the PCI devices / PCI cards?

Sorry, may be would need you to provide a big picture to this. Thanks. :)

> 
> > Anyway, I can change the fix by adding the clock registration APIs
> > being call at the stmmac_pci.c probe there before calling
> > stmmac_dvr_probe. By doing this, it created a dependency to the pci
> > driver that must have CONFIG_HAVE_CLK to be turned on. Besides, I
> would need you guys to provide me information on other platforms about
> what is the best value to set? Can I just set to zero since the stmmac_pci
> driver is always using the priv->plat->clk_csr?
> >
