From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Wed, 18 Jul 2012 09:07:07 -0700 (PDT)
Message-ID: <20120718.090707.1241941591837985005.davem@davemloft.net>
References: <alpine.LFD.2.00.1207181014050.1652@ja.ssi.bg>
	<1342596648.2626.1831.camel@edumazet-glaptop>
	<alpine.LFD.2.00.1207181105320.2154@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab2GRQHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:07:08 -0400
In-Reply-To: <alpine.LFD.2.00.1207181105320.2154@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 18 Jul 2012 11:36:08 +0300 (EEST)

> 	Is the cost of read_seqbegin a problem? Here is a
> 2nd version, I still keep this first check for now.

No, the read side of seqlocks are extremely cheap, it's just a plain
read and compare of a read-mostly integer.

> Subject: [PATCH v2] ipv4: use seqlock for nh_exceptions
> 
> From: Julian Anastasov <ja@ssi.bg>
> 
> 	Use global seqlock for the nh_exceptions. Call
> fnhe_oldest with the right hash chain. Correct the diff
> value for dst_set_expires.
> 
> v2: after suggestions from Eric Dumazet:
> * get rid of spin lock fnhe_lock, rearrange update_or_create_fnhe
> * continue daddr search in rt_bind_exception
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

I think if you get a seqlock mis-compare, you will need to branch back
to rescan the hash chain from the beginning.

Otherwise I like these changes a lot.

We should perhaps consider doing something similar in the TCP metrics
code.

Thanks!
