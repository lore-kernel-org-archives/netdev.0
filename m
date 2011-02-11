From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [PATCH net-2.6] ixgbe: fix panic due to uninitialied pointer
Date: Fri, 11 Feb 2011 14:47:25 -0800
Message-ID: <29F4ED941D916B48B88B4D2A4F3D1B9C01D2D70082@orsmsx509.amr.corp.intel.com>
References: <1297460747-31896-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Andy Gospodarek <andy@greyhouse.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11490 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758373Ab1BKWr2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 17:47:28 -0500
In-Reply-To: <1297460747-31896-1-git-send-email-andy@greyhouse.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Andy Gospodarek [mailto:andy@greyhouse.net]
>Sent: Friday, February 11, 2011 1:46 PM
>To: netdev@vger.kernel.org
>Cc: Skidmore, Donald C; Duyck, Alexander H; Kirsher, Jeffrey T; Rose,
>Gregory V
>Subject: [PATCH net-2.6] ixgbe: fix panic due to uninitialied pointer
>
>Systems containing an 82599EB and running a backported driver from
>upstream were panicing on boot.  It turns out hw->mac.ops.setup_sfp is
>only set for 82599, so one should check to be sure that pointer is set
>before continuing in ixgbe_sfp_config_module_task.  I verified by
>inspection that the upstream driver has the same issue and also added a
>check before the call in ixgbe_sfp_link_config.
>
>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>---
> drivers/net/ixgbe/ixgbe_main.c |    6 ++++--
> 1 files changed, 4 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/ixgbe/ixgbe_main.c
>b/drivers/net/ixgbe/ixgbe_main.c
>index fbae703..30f9ccf 100644
>--- a/drivers/net/ixgbe/ixgbe_main.c
>+++ b/drivers/net/ixgbe/ixgbe_main.c
>@@ -3728,7 +3728,8 @@ static void ixgbe_sfp_link_config(struct
>ixgbe_adapter *adapter)
> 			 * We need to try and force an autonegotiation
> 			 * session, then bring up link.
> 			 */
>-			hw->mac.ops.setup_sfp(hw);
>+			if (hw->mac.ops.setup_sfp)
>+				hw->mac.ops.setup_sfp(hw);
> 			if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
> 				schedule_work(&adapter->multispeed_fiber_task);
> 		} else {
>@@ -5968,7 +5969,8 @@ static void ixgbe_sfp_config_module_task(struct
>work_struct *work)
> 		unregister_netdev(adapter->netdev);
> 		return;
> 	}
>-	hw->mac.ops.setup_sfp(hw);
>+	if (hw->mac.ops.setup_sfp)
>+		hw->mac.ops.setup_sfp(hw);
>
> 	if (!(adapter->flags & IXGBE_FLAG_IN_SFP_LINK_TASK))
> 		/* This will also work for DA Twinax connections */
>--
>1.7.4

Thanks for the patch.  Jeff will pull it into our tree and we will give it some testing but it looks good to me.

-Don Skidmore <donald.c.skidmore@intel.com> 
