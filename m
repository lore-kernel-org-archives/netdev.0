From: "Jens Renner (EFE)" <renner@efe-gmbh.de>
Subject: Re: [PATCH v2 0/6] Emaclite patches
Date: Fri, 31 May 2013 11:10:23 +0200
Message-ID: <51A868FF.5070903@efe-gmbh.de>
References: <cover.1369909618.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Michal Simek <monstr@monstr.eu>, netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:57817 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753278Ab3EaJKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 05:10:10 -0400
In-Reply-To: <cover.1369909618.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 30.05.2013 12:28, schrieb Michal Simek:
> I have separated these emaclite patches from phy patches because it is
> easier for creating new versions.
> 
> Thanks, Michal
> 
> Changes in v2: - Fix __raw_iowrite() to pass correct parameters -
> s/Corrent/Correct/ in patch description
> 
> Michal Simek (6): net: emaclite: Report failures in mdio setup net:
> emaclite: Support multiple phys connected to one MDIO bus net: emaclite:
> Let's make xemaclite_adjust_link static net: emaclite: Do not use
> microblaze and ppc IO functions net: emaclite: Enable emaclite for Xilinx
> Arm Zynq platform net: emaclite: Update driver header
> 
> drivers/net/ethernet/xilinx/Kconfig           |   4 +- 
> drivers/net/ethernet/xilinx/xilinx_emaclite.c | 169
> ++++++++++++++------------ 2 files changed, 95 insertions(+), 78
> deletions(-)

Works without problems on our Microblaze platform (as far as the patches affect
our functionality). MDIO verbosity has been tested ok.

> @@ -862,8 +864,10 @@ static int xemaclite_mdio_setup(struct net_local *lp,
struct device *dev)
> XEL_MDIOCTRL_MDIOEN_MASK);
> 
> bus = mdiobus_alloc(); -	if (!bus) +	if (!bus) { +		dev_err(dev, "Failed to
> allocal mdiobus\n"); return -ENOMEM; +	}
> 
> of_address_to_resource(np, 0, &res); snprintf(bus->id, MII_BUS_ID_SIZE,
> "%.8llx",

Shouldn't the wording be "allocate" instead of "allocal" in PATCH v2 1/6 (net:
emaclite: Report failures in mdio setup)?
Regards
Jens.
