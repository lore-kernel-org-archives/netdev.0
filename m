From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/2] igb: Revert support for build_skb in igb
Date: Thu, 18 Apr 2013 14:52:43 -0400 (EDT)
Message-ID: <20130418.145243.2239743321858687644.davem@davemloft.net>
References: <1366267264-18355-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab3DRSwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:52:51 -0400
In-Reply-To: <1366267264-18355-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 17 Apr 2013 23:41:04 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch actually reverts:
> igb: Support using build_skb in the case that jumbo frames are disabled
> 
> The reason for reverting this patch is that it can lead to data corruption.
> The following flow was pointed out by Ben Hutchings:
> 
> 1. skb is forwarded to another device
> 2. Packet headers are modified and it's put into a queue
> 3. Second packet is received into the other half of this page
> 4. Page cannot be reused, so is DMA-unmapped
> 5. The DMA mapping was non-coherent, so unmap copies or invalidates
> cache
> 
> The headers added in step 2 get trashed in step 5.
> 
> Reported-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
