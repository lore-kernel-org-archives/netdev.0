From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] macvlan: fix netdev feature propagation from lower
 device
Date: Thu, 26 Dec 2013 13:41:38 -0500 (EST)
Message-ID: <20131226.134138.788504695045417458.davem@davemloft.net>
References: <1388056620-2008-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753568Ab3LZSlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:41:40 -0500
In-Reply-To: <1388056620-2008-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 26 Dec 2013 12:17:00 +0100

> There are inconsistencies wrt. feature propagation/inheritance between
> macvlan and the underlying interface.
> 
> When a feature is turned off on the real device before a macvlan is
> created on top, these will remain enabled on the macvlan device, whereas
> turning off the feature on the lower device after macvlan creation the
> kernel will propagate the changes to the macvlan.
> 
> The second issue is that, when propagating changes from underlying device
> to the macvlan interface, macvlan can erronously lose its NETIF_F_LLTX flag,
> as features are anded with the underlying device.
> 
> However, LLTX should be kept since it has no dependencies on physical
> hardware (LLTX is set on macvlan creation regardless of the lower
> device properties, see 8ffab51b3dfc54876f145f15b351c41f3f703195
> (macvlan: lockless tx path).
> 
> The LLTX flag is now forced regardless of user settings in absence of
> layer2 hw acceleration (a6cc0cfa72e0b6d9f2c8fd858aa,
> net: Add layer 2 hardware acceleration operations for macvlan devices).
> 
> Use netdev_increment_features to rebuild the feature set on capability
> changes on either the lower device or on the macvlan interface.
> 
> As pointed out by Ben Hutchings, use netdev_update_features on
> NETDEV_FEAT_CHANGE event (it calls macvlan_fix_features/netdev_features_change
> if needed).
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Changes since v1:
>  - use netdev_update_features on NETDEV_FEAT_CHANGE event

Applied and queued up for -stable, thanks!
