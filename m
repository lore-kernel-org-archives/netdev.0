From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] bnx2: Prevent "scheduling while atomic" warning
 with cnic, bonding and vlan.
Date: Tue, 27 Apr 2010 14:38:34 -0700 (PDT)
Message-ID: <20100427.143834.35819121.davem@davemloft.net>
References: <1272403691-2934-1-git-send-email-mchan@broadcom.com>
	<1272403691-2934-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, jfeeney@redhat.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36845
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757159Ab0D0Vi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:38:28 -0400
In-Reply-To: <1272403691-2934-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 27 Apr 2010 14:28:10 -0700

> The bonding driver calls ndo_vlan_rx_register() while holding bond->lock.
> The bnx2 driver calls bnx2_netif_stop() to stop the rx handling while
> changing the vlgrp.  The call also stops the cnic driver which sleeps
> while the bond->lock is held and cause the warning.
> 
> This code path only needs to stop the NAPI rx handling while we are
> changing the vlgrp.  Since no reset is going to occur, there is no need
> to stop cnic in this case.  By adding a parameter to bnx2_netif_stop()
> to skip stopping cnic, we can avoid the warning.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied to net-2.6
