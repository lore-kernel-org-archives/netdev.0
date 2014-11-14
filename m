From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "fast_hash: avoid indirect function
 calls"
Date: Fri, 14 Nov 2014 16:36:48 -0500 (EST)
Message-ID: <20141114.163648.2078151952004168592.davem@davemloft.net>
References: <1415979978.15154.41.camel@localhost>
	<20141114.133829.1437047454714311242.davem@davemloft.net>
	<16481.1415991906@famine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, discuss@openvswitch.org
To: jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161843AbaKNVgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 16:36:51 -0500
In-Reply-To: <16481.1415991906@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <jay.vosburgh@canonical.com>
Date: Fri, 14 Nov 2014 11:05:06 -0800

> 
> This reverts commit e5a2c899957659cd1a9f789bc462f9c0b35f5150.
> 
> 	Commit e5a2c899 introduced an alternative_call, arch_fast_hash2,
> that selects between __jhash2 and __intel_crc4_2_hash based on the
> X86_FEATURE_XMM4_2.
> 
> 	Unfortunately, the alternative_call system does not appear to be
> suitable for use with C functions, as register usage is not handled
> properly for the called functions.  The __jhash2 function in particular
> clobbers registers that are not preserved when called via
> alternative_call, resulting in a panic for direct callers of
> arch_fast_hash2 on older CPUs lacking sse4_2.  It is possible that
> __intel_crc4_2_hash works merely by chance because it uses fewer
> registers.
> 
> 	This commit was suggested as the source of the problem by Jesse
> Gross <jesse@nicira.com>.
> 
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

Applied, thanks Jay.
