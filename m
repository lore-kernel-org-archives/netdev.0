From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a
 cond_resched()
Date: Wed, 14 Nov 2007 16:13:08 -0800 (PST)
Message-ID: <20071114.161308.66154917.davem@davemloft.net>
References: <473B69D5.2050805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753804AbXKOANI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 19:13:08 -0500
In-Reply-To: <473B69D5.2050805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 14 Nov 2007 22:34:13 +0100

> On commit 39c90ece7565f5c47110c2fa77409d7a9478bd5b we converted 
> rt_check_expire() from softirq to workqueue, allowing the function to perform 
> all work it was supposed to do.
> 
> When the IP route cache is big, rt_check_expire() can take a long time to run.
> (default settings : 20% of the hash table is scanned at each invocation)
> 
> Adding cond_resched() helps giving cpu to higher priority tasks if necessary.
> 
> Using a "if (need_resched())" test before calling "cond_resched();" is 
> necessary to avoid spending too much time doing the resched check.
> (My tests gave a time reduction from 88 ms to 25 ms per rt_check_expire() run 
> on my i686 test machine)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Patch applied, thanks!
