From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Always allocate at least 16 skb frags regardless
 of page size
Date: Mon, 28 Mar 2011 22:27:02 -0700 (PDT)
Message-ID: <20110328.222702.39186706.davem@davemloft.net>
References: <20110328115726.4cca214d@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59488
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751665Ab1C2F1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 01:27:40 -0400
In-Reply-To: <20110328115726.4cca214d@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Mon, 28 Mar 2011 11:57:26 +1100

> 
> When analysing performance of the cxgb3 on a ppc64 box I noticed that
> we weren't doing much GRO merging. It turns out we are limited by the
> number of SKB frags:
> 
> #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
> 
> With a 4kB page size we have 18 frags, but with a 64kB page size we
> only have 3 frags.
> 
> I ran a single stream TCP bandwidth test to compare the performance of
> different values of MAX_SKB_FRAGS on the receiver:
> 
> MAX_SKB_FRAGS   Mbps
> 3               7080	
> 8               7931    (+12%)
> 16              8335	(+17%)
> 32              8349	(+17%)
> 
> Performance continues to increase up to 16 frags then levels off so
> the patch below puts a lower bound of 16 on MAX_SKB_FRAGS.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>

Thanks for investigating this and fixing the problem.

Applied.
