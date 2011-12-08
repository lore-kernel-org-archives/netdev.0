From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] powerpc: Add TBI PHY node to first MDIO bus
Date: Thu, 8 Dec 2011 01:23:36 -0600
Message-ID: <D23C5FF8-F960-486D-9F11-5BCE61D0A9BC@kernel.crashing.org>
References: <1323287457-6085-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59274 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410Ab1LHHXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 02:23:34 -0500
In-Reply-To: <1323287457-6085-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 7, 2011, at 1:50 PM, Andy Fleming wrote:

> Systems which use the fsl_pq_mdio driver need to specify an
> address for TBI PHY transactions such that the address does
> not conflict with any PHYs on the bus (all transactions to
> that address are directed to the onboard TBI PHY). The driver
> used to scan for a free address if no address was specified,
> however this ran into issues when the PHY Lib was fixed so
> that all MDIO transactions were protected by a mutex. As it
> is, the code was meant to serve as a transitional tool until
> the device trees were all updated to specify the TBI address.
> 
> The best fix for the mutex issue was to remove the scanning code,
> but it turns out some of the newer SoCs have started to omit
> the tbi-phy node when SGMII is not being used. As such, these
> devices will now fail unless we add a tbi-phy node to the first
> mdio controller.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
> 
> This requires fsl_pq_mdio: Clean up tbi address configuration from
> the net tree in order to achieve its full effect.
> 
> This needs to go into 3.2.
> 
> arch/powerpc/boot/dts/p1010rdb.dts            |    5 +++++
> arch/powerpc/boot/dts/p1020rdb.dts            |    5 +++++
> arch/powerpc/boot/dts/p1020rdb_camp_core0.dts |    5 +++++
> arch/powerpc/boot/dts/p1021mds.dts            |    4 ++++
> arch/powerpc/boot/dts/p1022ds.dts             |    4 ++++
> arch/powerpc/boot/dts/p2020rdb.dts            |    8 ++++++--
> arch/powerpc/boot/dts/p2020rdb_camp_core0.dts |    4 ++++
> 7 files changed, 33 insertions(+), 2 deletions(-)

applied to merge

- k
