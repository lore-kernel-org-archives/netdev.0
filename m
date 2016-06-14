From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: alx: Work around the DMA RX overflow issue
Date: Tue, 14 Jun 2016 15:31:54 -0400 (EDT)
Message-ID: <20160614.153154.267530721453507462.davem@davemloft.net>
References: <1465724197-26253-1-git-send-email-feng.tang@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, johannes@sipsolutions.net,
	jarod@redhat.com, netdev@vger.kernel.org
To: feng.tang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49133 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbcFNTb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 15:31:57 -0400
In-Reply-To: <1465724197-26253-1-git-send-email-feng.tang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feng Tang <feng.tang@intel.com>
Date: Sun, 12 Jun 2016 17:36:37 +0800

> Commit 26c5f03 uses a new skb allocator to avoid the RFD overflow
> issue.
> 
> But from debugging without datasheet, we found the error always
> happen when the DMA RX address is set to 0x....fc0, which is very
> likely to be a HW/silicon problem.
> 
> So one idea is instead of adding a new allocator, why not just
> hitting the right target by avaiding the error-prone DMA address?
> 
> This patch will actually
> * Remove the commit 26c5f03
> * Apply rx skb with 64 bytes longer space, and if the allocated skb
>   has a 0x...fc0 address, it will use skb_resever(skb, 64) to
>   advance the address, so that the RX overflow can be avoided.
> 
> In theory this method should also apply to atl1c driver, which
> I can't find anyone who can help to test on real devices.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=70761
> Signed-off-by: Feng Tang <feng.tang@intel.com>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Ole Lukoie <olelukoie@mail.ru>

Applied.
