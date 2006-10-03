From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] Fixes for net-2.6
Date: Tue, 03 Oct 2006 15:55:04 -0700 (PDT)
Message-ID: <20061003.155504.126762903.davem@davemloft.net>
References: <4521D932.8050502@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51129
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030560AbWJCWzC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 18:55:02 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <4521D932.8050502@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Tue, 03 Oct 2006 12:29:54 +0900

>     [XFRM] POLICY: Fix per-direction policy counter after flushing.
> 
>     Currently when xfrm_policy_flush() is called per-direction
>     policy counter is cleared. However flusing policy is performed
>     for each type (i.e. main or sub) then it is not always true
>     to make the counter zero.
> 
>     Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

The idea of this code is to avoid updating global state many
many times during such a flush.  This can be expensive and
cause much SMP cacheline activity as other cpus read the
counter in the routing lookup path.

I think what I'll do is reimplement this patch so that a local
variable is used to maintain how many entries were removed,
and then simply subtract that counter from xfrm_policy_count[dir]
at the very end where the assignment to zero occurs.

>     [XFRM] STATE: Use destination address for src hash.
> 
>     Src hash is introduced for Mobile IPv6 route optimization usage.
>     On current kenrel code it is calculated with source address only.
>     It results we uses the same hash value for outbound state (when
>     the node has only one address for Mobile IPv6).
>     This patch use also destination address as peer information for
>     src hash to be dispersed.
> 
>     Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

This patch is fine, I will apply this, thank you.
