From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] IPV4: route rekey timer can be deferrable
Date: Thu, 10 Apr 2008 01:55:56 -0700 (PDT)
Message-ID: <20080410.015556.143133279.davem@davemloft.net>
References: <20080401004708.009204033@vyatta.com>
	<20080401004724.826913057@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41059
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750794AbYDJIz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 04:55:59 -0400
In-Reply-To: <20080401004724.826913057@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 31 Mar 2008 17:47:14 -0700

> No urgency on the rehash interval timer, so mark it as deferrable.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6.26, thanks.

> -	setup_timer(&rt_secret_timer, rt_secret_rebuild, 0);
> +	rt_secret_timer.function = rt_secret_rebuild;
> +	rt_secret_timer.data = 0;
> +	init_timer_deferrable(&rt_secret_timer);

I've seen enough of these that a setup_timer_deferrable()
might be appropriate.
