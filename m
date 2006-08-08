From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [PATCH] limit rt cache size
Date: Tue, 08 Aug 2006 16:54:40 +0400
Message-ID: <44D88990.3090904@sw.ru>
References: <200608080711.06788.ak@suse.de>	<20060807.231834.48498773.davem@davemloft.net>	<200608080853.03510.ak@suse.de> <20060808.000110.110010976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:48053 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S964879AbWHHMxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 08:53:53 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.000110.110010976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Andi Kleen <ak@suse.de>
> Date: Tue, 8 Aug 2006 08:53:03 +0200
> 
> 
>>That's still too big. Consider a 2TB machine, with all memory in LOWMEM.
> 
> 
> Andi I agree with you, route.c should pass in a suitable limit.
> I'm just suggesting a fix for a seperate problem.

So summaring up we have the following issues imho:
1a) rt hash size should be calculated based on lowmem size, not total size
1b) rt hash size should have some upper limit (requested by Andi Kleen for huge mem systems)
2a) max number of rt hash entries should be calculated based on low memory, not as
   rt_hash_chains*16.
2b) when CONFIG_DEBUG_SLAB and CONFIG_DEBUG_PAGE_ALLOC are ON, 2a) should be corrected
   taking into account _real_ rtable entry size (one page instead of 256b!!!).
3) should we limit TCP hashe and hashb size the same way?

If I haven't missed something I will prepare a patch for 1-2) and
a separate patch for 3).

Thanks,
Kirill
