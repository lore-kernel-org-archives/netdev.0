From: Anders Darander <anders.darander@datarespons.se>
Subject: Re: [PATCH] Allow MACB to connect to a higher addresses PHY.
Date: Wed, 31 Mar 2010 07:53:06 +0200
Message-ID: <20100331055306.GC4837@datarespons.se>
References: <1269943112-6975-1-git-send-email-anders.darander@gmail.com>
 <fa686aa41003300741x5ef9bdbpf56133304fe4d6e6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	Maxime Bizon <mbizon@freebox.fr>,
	David Daney <ddaney@caviumnetworks.com>,
	Sekhar Nori <nsekhar@ti.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.datarespons.com ([81.0.189.39]:1538 "EHLO
	mailgw01.datarespons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932247Ab0CaGDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:03:49 -0400
Content-Disposition: inline
In-Reply-To: <fa686aa41003300741x5ef9bdbpf56133304fe4d6e6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

Thanks for the feedback!

* Grant Likely <grant.likely@secretlab.ca> [100330 16:42]:
> On Tue, Mar 30, 2010 at 3:58 AM, Anders Darander
> <anders.darander@gmail.com> wrote:
> > Using the Atmel MACB together with an integrated switch, can make only port 1
> > work. This is caused by macb_mii_probe trying to attach the MAC to the first
> > PHY, which often is on one of the external ports.
> >
> > E.g. the Micrel KSZ8873 connects to the MAC on port 3, thus phy_addr should be
> > set to 3.

> I understand what you are trying to do, but this is the wrong way to
> go about it.  Hard coding it into Kconfig breaks multiplatform
> kernels.  Besides, systems may have more than one physical MDIO bus.
> This patch would make CONFIG_SWITCHING_PHY_ADDR the only address
> accessible on all MDIO busses.

True, it would at least make all addresses < CONFIG_SWITCHING_PHY_ADDR
non-accessible.

We developed the patch to solve this problem on a 2.6.29-kernel, in
which the loop in question is directly in the macb_mii_probe() in the
macb.c, thus, the original patch is at least a _little_ bit less ugly...

> Nak.

I fully agree on the nak; I completely forgot that the functions in
phy_devices should be used from more interfaces than only the macb.

> The right thing to do is to add a runtime configuration option (ie.
> kernel parameter or platform data) to the mac driver to specify
> exactly which PHY address it is supposed to use.

I'll see if I can get some time to do such a thing. Unfortunately, it'll
probably have to be dealt with on my sparetime (the customer is quite
unlikely to let me work on that).

One question, if I add such an kernel parameter, would it be OK to
implement something like this in the macb-driver:

if parameter == SOME_DEFAULT
	phydev = phy_find_first(bp->mii_bus);
else
	phydev = bp->mii_bus->phy_map[parameter];

I.e. if the parameter is set to some default value, the old behaviour is
retained, otherwise the specified parameter is used for the phy_addr?

I'd appreciate your input on such a design.

Best regards,
Anders Darander

