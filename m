From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [PATCH] of: of_mdio: Add marvell,88e1145 to whitelist of PHY
 compatibilities.
Date: Wed, 3 Feb 2016 22:50:25 +0200
Message-ID: <20160203205024.GC1620@darkstar.musicnaut.iki.fi>
References: <1454528129-6144-1-git-send-email-aaro.koskinen@iki.fi>
 <20160203200857.GA10262@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <ddaney@caviumnetworks.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh04.mail.saunalahti.fi ([62.142.5.110]:42905 "EHLO
	emh04.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089AbcBCUu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 15:50:28 -0500
Content-Disposition: inline
In-Reply-To: <20160203200857.GA10262@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Feb 03, 2016 at 09:08:57PM +0100, Andrew Lunn wrote:
> On Wed, Feb 03, 2016 at 09:35:29PM +0200, Aaro Koskinen wrote:
> > Commit ae461131960b ("of: of_mdio: Add a whitelist of PHY
> > compatibilities.") missed one compatible string used in in-tree DTBs:
> > in OCTEON, for selected boards, the kernel DTB pruning code will overwrite
> > the DTB compatible string with "marvell,88e1145", which is missing
> > from the whitelist. Add it.
> 
> Does this overwriting means this compatibility is not visible in the
> current DTS files? Or did i miss it?

Yeah, it happens in arch/mips/cavium-octeon/octeon-platform.c:

        if (octeon_has_88e1145()) {
                fdt_nop_property(initial_boot_params, phy, "marvell,reg-init");
                memset(new_name, 0, sizeof(new_name));
                strcpy(new_name, "marvell,88e1145");

It took a while for me to figure out this as well... Nasty.

> At least for the Marvell SoCs i intend to submit a patch removing
> these compatible strings from the DTS files. Will you do the same for
> the OCTEON boards?

Yes, for in-tree OCTEON DTS files, I can do the update; the above strcpy
needs to be deleted at the same go, and this needs go through MIPS tree.

A.
