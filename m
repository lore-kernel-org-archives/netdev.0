From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: don't enable multicast flag in
 be_enable_if_filters() routine
Date: Thu, 03 Mar 2016 17:18:22 -0500 (EST)
Message-ID: <20160303.171822.1938866282727633481.davem@davemloft.net>
References: <1456916428-30413-1-git-send-email-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivecera@redhat.com
To: sathya.perla@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758184AbcCCWSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:18:24 -0500
In-Reply-To: <1456916428-30413-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>
Date: Wed,  2 Mar 2016 06:00:28 -0500

> From: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>
> 
> When the interface is opened (in be_open()) the routine
> be_enable_if_filters() must be called to switch on the basic filtering
> capabilities of an interface that are not changed at run-time.
> These include the flags UNTAGGED, BROADCAST and PASS_L3L4_ERRORS.
> Other flags such as MULTICAST and PROMISC must be enabled later by
> be_set_rx_mode() based on the state in the netdev/adapter struct.
> 
> be_enable_if_filters() routine is wrongly trying to enable MULTICAST flag
> without checking the current adapter state. This can cause the RX_FILTER
> cmds to the FW to fail.  This patch fixes this problem by only enabling
> the basic filtering flags in be_enable_if_filters().
> 
> The VF must be able to issue RX_FILTER cmd with any filter flag, as long
> as the PF allowed those flags (if_cap_flags) in the iface it provisioned
> for the VF. This rule is applicable even when the VF doesn't have the
> FILTMGMT privilege. There is a bug in BE3 FW that wrongly fails RX_FILTER
> multicast programming cmds on VFs that don't have FILTMGMT privilege.
> This patch also helps in insulating the VF driver from be_open failures due
> to the FW bug. A fix for the BE3 FW issue will be available in
> versions >= 11.0.283.0 and 10.6.334.0
> 
> Reported-by: Ivan Vecera <ivecera@redhat.com>
> Signed-off-by: Venkat Duvvuru <venkatkumar.duvvuru@avagotech.com>
> Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>

Applied, thank you.
