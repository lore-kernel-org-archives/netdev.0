From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: [PATCH] of: of_mdio: Add marvell,88e1145 to whitelist of PHY
 compatibilities.
Date: Wed, 3 Feb 2016 23:21:19 +0200
Message-ID: <20160203212119.GD1620@darkstar.musicnaut.iki.fi>
References: <1454528129-6144-1-git-send-email-aaro.koskinen@iki.fi>
 <20160203200857.GA10262@lunn.ch>
 <56B25F8D.6070809@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh04.mail.saunalahti.fi ([62.142.5.110]:43772 "EHLO
	emh04.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755484AbcBCVVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 16:21:21 -0500
Content-Disposition: inline
In-Reply-To: <56B25F8D.6070809@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Feb 03, 2016 at 12:14:05PM -0800, David Daney wrote:
> On 02/03/2016 12:08 PM, Andrew Lunn wrote:
> >On Wed, Feb 03, 2016 at 09:35:29PM +0200, Aaro Koskinen wrote:
> >>Commit ae461131960b ("of: of_mdio: Add a whitelist of PHY
> >>compatibilities.") missed one compatible string used in in-tree DTBs:
> >>in OCTEON, for selected boards, the kernel DTB pruning code will overwrite
> >>the DTB compatible string with "marvell,88e1145", which is missing
> >>from the whitelist. Add it.
> >
> >Does this overwriting means this compatibility is not visible in the
> >current DTS files? Or did i miss it?
> >
> >At least for the Marvell SoCs i intend to submit a patch removing
> >these compatible strings from the DTS files. Will you do the same for
> >the OCTEON boards?
> 
> The compatibility strings may be present in deployed firmware, they cannot
> be removed. For many OCTEON boards, the device tree is a firmware-kernel
> ABI, it is not practical to unilaterally decide to change the bindings on
> the kernel side as you don't control the firmware.

I agree from practical point of view, but OTOH kernel has never accepted
those bindings as an ABI.

Now users may need to put up with warnings like:

[Firmware Warn]: /soc@0/mdio@1180000001800/ethernet-phy@7: Whitelisted compatible string. Please remove
[Firmware Warn]: /soc@0/mdio@1180000001800/ethernet-phy@6: Whitelisted compatible string. Please remove

if the strings are not updated.

If user loses PHY (like now with EdgeRouter Lite), the string need
to be added to the whitelist. Cannot say if this will be an issue for
firmware DTB OCTEON users; the only firmware DTB board (EdgeRouter Pro)
I have seems to provide correct strings:

	broadcom,bcm ethernet-phy-ieee802.3-c22

A.
