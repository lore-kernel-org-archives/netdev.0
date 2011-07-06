From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: fix starving rx ring whenoc_skb kb fails
Date: Tue, 05 Jul 2011 18:40:35 -0700 (PDT)
Message-ID: <20110705.184035.2294830861687805068.davem@davemloft.net>
References: <1308312860.11457.56.camel@localhost>
	<20110617.120900.550060204741705506.davem@davemloft.net>
	<alpine.LRH.2.00.1107051721230.32629@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, scottjg@vmware.com
To: sbhatewara@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51030 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445Ab1GFBkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 21:40:37 -0400
In-Reply-To: <alpine.LRH.2.00.1107051721230.32629@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Tue, 5 Jul 2011 17:34:05 -0700 (PDT)

> 
> If the rx ring is completely empty, then the device may never fire an rx 
> interrupt. Unfortunately, the rx interrupt is what triggers populating the 
> rx ring with fresh buffers, so this will cause networking to lock up.
> 
> This patch replenishes the skb in recv descriptor as soon as it is 
> peeled off while processing rx completions. If the skb/buffer 
> allocation fails, existing one is recycled and the packet in hand is 
> dropped. This way none of the RX desc is ever left empty, thus avoiding 
> starvation
> 
> Signed-off-by: Scott J. Goldman <scottjg@vmware.com>
> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>

Applied.
