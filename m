From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] net: Fix ucc_geth.c handling of phy 'interface' property.
Date: Mon, 27 Apr 2009 12:36:06 -0500
Message-ID: <20090427173606.GA10292@ld0162-tx32.am.freescale.net>
References: <20090427153612.5108.10877.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	Andy Fleming <afleming@freescale.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:50037 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbZD0RgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 13:36:25 -0400
Received: from de01smr02.am.mot.com (de01smr02.freescale.net [10.208.0.151])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n3RHa7al020046
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 10:36:18 -0700 (MST)
Received: from ld0162-tx32.am.freescale.net (ld0162-tx32.am.freescale.net [10.82.19.112])
	by de01smr02.am.mot.com (8.13.1/8.13.0) with ESMTP id n3RHa6pM001513
	for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 12:36:07 -0500 (CDT)
Content-Disposition: inline
In-Reply-To: <20090427153612.5108.10877.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2009 at 09:36:13AM -0600, Grant Likely wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> 
> Previous rework to ucc_geth.c to add of_mdio support (net: Rework
> ucc_geth driver to use of_mdio infrastructure) added a block of
> code which broke older openfirmware device trees which use an
> 'interface' property in the phy node to describe the connection
> between the MAC and the PHY.  This patch removes the offending blurb.
[snip]
>  	prop = of_get_property(np, "phy-connection-type", NULL);
>  	if (!prop) {
>  		/* handle interface property present in old trees */
> -		if (!phy)
> -			return -ENODEV;
> -
>  		prop = of_get_property(phy, "interface", NULL);
>  		if (prop != NULL) {
>  			phy_interface = enet_to_phy_interface[*prop];

The above test only makes a difference when there is no phy node -- so I
don't see how it was breaking device trees that had a phy node (with or
without an "interface" property).  I can see it breaking fixed link
device trees, though.

-Scott
