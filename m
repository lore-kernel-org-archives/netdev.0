From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 1/4] tcp: Fix truesize accounting in tcp_try_coalesce
Date: Thu, 03 May 2012 04:21:59 -0400 (EDT)
Message-ID: <20120503.042159.938231117013356970.davem@davemloft.net>
References: <20120503071141.13636.37564.stgit@gitlad.jf.intel.com>
	<20120503071859.13636.30050.stgit@gitlad.jf.intel.com>
	<1336031334.3503.23.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab2ECIWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 04:22:05 -0400
In-Reply-To: <1336031334.3503.23.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 May 2012 09:48:54 +0200

> On Thu, 2012-05-03 at 00:18 -0700, Alexander Duyck wrote:
>> This patch addresses several issues in the way we were tracking the
>> truesize in tcp_try_coalesce.
>> 
>> First it was using ksize which prevents us from having a 0 sized head frag
>> and getting a usable result.  To resolve that this patch uses the end
>> pointer which is set based off either ksize, or the frag_size supplied in
>> build_skb.  This allows us to compute the original truesize of the entire
>> buffer and remove that value leaving us with just what was added as pages.
>> 
>> The second issue was the use of skb->len if there is a mergeable head frag.
>> We should only need to remove the size of an data aligned sk_buff from our
>> current skb->truesize to compute the delta for a buffer with a reused head.
>> By using skb->len the value of truesize was being artificially reduced
>> which means that head frags could use more memory than buffers using
>> standard allocations.
>> 
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
 ...
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
