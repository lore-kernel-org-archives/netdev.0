From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/smsc911x: Fix delays in the PHY enable/disable
 routines
Date: Thu, 13 Nov 2014 14:38:19 -0500 (EST)
Message-ID: <20141113.143819.260825175683568897.davem@davemloft.net>
References: <1415841980-14250-1-git-send-email-al.kochet@gmail.com>
	<1415841980-14250-2-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net
To: al.kochet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933615AbaKMTiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 14:38:21 -0500
In-Reply-To: <1415841980-14250-2-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Kochetkov <al.kochet@gmail.com>
Date: Thu, 13 Nov 2014 05:26:20 +0400

> Increased delay in the smsc911x_phy_disable_energy_detect (from 1ms to 2ms).
> Dropped delays in the smsc911x_phy_enable_energy_detect (100ms and 1ms).
> 
> The patch affect SMSC LAN generation 4 chips with integrated PHY (LAN9221).
> 
> I saw problems with soft reset due to wrong udelay timings.
> After I fixed udelay, I measured the time needed to bring integrated PHY
> from power-down to operational mode (the time beetween clearing EDPWRDOWN
> bit and soft reset complete event). I got 1ms (measured using ktime_get).
> The value is equal to the current value (1ms) used in the
> smsc911x_phy_disable_energy_detect. It is near the upper bound and in order
> to avoid rare soft reset faults it is doubled (2ms).
> 
> I don't know official timing for bringing up integrated PHY as specs doesn't
> clarify this (or may be I didn't found).
> 
> It looks safe to drop delays before and after setting EDPWRDOWN bit
> (enable PHY power-down mode). I didn't saw any regressions with the patch.
> 
> The patch was reviewed by Steve Glendinning and Microchip Team.
> 
> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
> Acked-by: Steve Glendinning <steve.glendinning@shawell.net>

Applied.
