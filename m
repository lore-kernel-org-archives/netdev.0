From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] net/mlx4_en: Use atomic counter to decide when
 queue is full
Date: Fri, 22 Jun 2012 17:23:53 -0700 (PDT)
Message-ID: <20120622.172353.1092394608024377078.davem@davemloft.net>
References: <1340270358-19504-1-git-send-email-yevgenyp@mellanox.co.il>
	<1340270358-19504-5-git-send-email-yevgenyp@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756690Ab2FWAXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2012 20:23:54 -0400
In-Reply-To: <1340270358-19504-5-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Thu, 21 Jun 2012 12:19:17 +0300

> The Transmit and transmit completion flows execute from different contexts,
> which are not synchronized. Hence naive reading the of consumer index might
> give wrong value by the time it is being used, That could lead to a state of transmit timeout.
> Fix that by using atomic variable to maintain that index.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

I'm not convinced.  There is only one place that actually changes
the counter.

So it seems more like you have a missing memory barrier somewhere.

Other drivers do not need to use something as expansive as an atomic
variable for this and neither should you.

I'm not applying this patch series, you'll need to resubmit it in
it's entirety once you fix this patch.
