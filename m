From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] Revert "fast_hash: avoid indirect function
 calls"
Date: Fri, 14 Nov 2014 22:43:02 +0100
Message-ID: <1416001382.15154.64.camel@localhost>
References: <1415978022.15154.31.camel@localhost>
	 <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1415979978.15154.41.camel@localhost>
	 <20141114.133829.1437047454714311242.davem@davemloft.net>
	 <16481.1415991906@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, discuss@openvswitch.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49217 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161966AbaKNVnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 16:43:06 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 7FFF220768
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 16:43:04 -0500 (EST)
In-Reply-To: <16481.1415991906@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-11-14 at 11:05 -0800, Jay Vosburgh wrote:
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

I am totally fine to revert this and try to come up with a better
solution.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Bye,
Hannes
