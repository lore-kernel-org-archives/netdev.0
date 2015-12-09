From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 1/4] stmmac: create of compatible mdio bus for stmacc driver
Date: Wed, 09 Dec 2015 10:22:20 +0100
Message-ID: <2980072.p4qU8YfBxO@wuerfel>
References: <201512091033.svvb9HL7%fengguang.wu@intel.com> <56679641.7060101@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	vbridger@opensource.altera.com, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:53628 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbbLIJWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 04:22:52 -0500
In-Reply-To: <56679641.7060101@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 09 December 2015 10:47:29 Phil Reid wrote:
> On 9/12/2015 10:15 AM, kbuild test robot wrote:
> 
> >
> > url:    https://github.com/0day-ci/linux/commits/Phil-Reid/stmmac-create-of-compatible-mdio-bus-for-stmacc-driver/20151209-094242
> > config: x86_64-randconfig-b0-12090825 (attached as .config)
> > reproduce:
> >          # save the attached .config to linux build tree
> >          make ARCH=x86_64
> >
> > All errors (new ones prefixed by >>):
> >
> >     drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c: In function 'stmmac_mdio_register':
> >>> drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c:226:17: error: 'struct stmmac_mdio_bus_data' has no member named 'reset_gpio'
> >         mdio_bus_data->reset_gpio = -1;
> >                      ^
> 
> G'day Arnd,
> 
> I got the above error from kbuild test robot. When changing to if (IS_ENABLED(CONFIG_OF)).
> This was existing code that I moved into this conditional.
> reset_gpio member only exists when CONFIG_OF is defined.
> So it looks like I need to move that code back to the #if.
> unless you have an alternate suggestion.

I think it would be slightly nicer to remove the #ifdef in the header file
as well and always have those members, it's only a few bytes in any system
that we are saving here and there are only two actual users of this driver
that don't already require CONFIG_OF (blackfin ezkit and mips loongson32).

If Giuseppe prefers to keep the #ifdef, going back to your previous
version is fine with me too.

	Arnd
