From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH net-next] igb: reset PHY after recovering from PHY power
 down
Date: Mon, 28 Nov 2011 09:57:37 -0800
Message-ID: <EDC0E76513226749BFBC9C3FB031318F01832E2C5C@orsmsx508.amr.corp.intel.com>
References: <4ECDB76F.1090104@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:30477 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752891Ab1K1R5j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 12:57:39 -0500
In-Reply-To: <4ECDB76F.1090104@jp.fujitsu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Koki Sanagi [mailto:sanagi.koki@jp.fujitsu.com]
>Sent: Wednesday, November 23, 2011 7:18 PM
>To: netdev@vger.kernel.org; Kirsher, Jeffrey T; Brandeburg, Jesse;
>Allan, Bruce W; Wyborny, Carolyn; Skidmore, Donald C; Rose, Gregory V;
>Waskiewicz Jr, Peter P; Duyck, Alexander H; Ronciak, John; e1000-
>devel@lists.sourceforge.net
>Cc: davem@davemloft.net
>Subject: [PATCH net-next] igb: reset PHY after recovering from PHY power
>down
>
>According to 82576_Datasheet.pdf, PHY setting is lost after PHY power
>down.
>So resetting PHY is needed when recovering from PHY power down to set a
>default
>setting to PHY register.
>
>Owing to this lack, NIC doesn't link up in some rare situation.
>The situation I encountered is following.
>
>
>1.Both ports connect to switch.
>+---------+           +--------+
>|         |-----------|        |
>| 82576NS |           | switch |
>|         |-----------|        |
>+---------+           +--------+
>
>2.Detach both cables from switch.
>+---------+           +--------+
>|         |-------    |        |
>| 82576NS |           | switch |
>|         |-------    |        |
>+---------+           +--------+
>
>3.Detach one cable from one port.
>+---------+           +--------+
>|         |-------    |        |
>| 82576NS |           | switch |
>|         |           |        |
>+---------+           +--------+
>
>4.Attach that cable to the other port.(It means connecting directly each
>port)
>+---------+           +--------+
>|         |-------+   |        |
>| 82576NS |       |   | switch |
>|         |-------+   |        |
>+---------+           +--------+
>
>As a result, NIC doesn't link up sometimes.
>
>Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>---
> drivers/net/ethernet/intel/igb/igb_main.c |    1 +
> 1 files changed, 1 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
>b/drivers/net/ethernet/intel/igb/igb_main.c
>index bd9b30e..4d4f065 100644
>--- a/drivers/net/ethernet/intel/igb/igb_main.c
>+++ b/drivers/net/ethernet/intel/igb/igb_main.c
>@@ -2496,6 +2496,7 @@ static int igb_open(struct net_device *netdev)
> 		goto err_setup_rx;
>
> 	igb_power_up_link(adapter);
>+	igb_reset_phy(hw);
>
> 	/* before we allocate an interrupt, we must be ready to handle it.
> 	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt

Hello,

This seems reasonable, however it would only cover cases where igb_open is being called.  It would be better to integrate the phy_reset call into igb_power_up_link, so that's the default. I can provide an alternate by end of the week.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
