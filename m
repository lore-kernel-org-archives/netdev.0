From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: Regression in net-2.6.24?
Date: Fri, 12 Oct 2007 19:22:00 +0900 (JST)
Message-ID: <20071012.192200.23848971.takano@axe-inc.co.jp>
References: <20071011165548.6545b207@freepuppy.rosehill>
	<20071011.171743.118962219.davem@davemloft.net>
	<20071011.181449.130846976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:61114 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbXJLKWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 06:22:08 -0400
In-Reply-To: <20071011.181449.130846976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Subject: Re: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 18:14:49 -0700 (PDT)

> 
> Here is what I'm checking into net-2.6 for now:
> 
> commit 6f535763165331bb91277d7519b507fed22034e5
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Thu Oct 11 18:08:29 2007 -0700
> 
>     [NET]: Fix NAPI completion handling in some drivers.
>     
>     In order for the list handling in net_rx_action() to be
>     correct, drivers must follow certain rules as stated by
>     this comment in net_rx_action():
>     
>     		/* Drivers must not modify the NAPI state if they
>     		 * consume the entire weight.  In such cases this code
>     		 * still "owns" the NAPI instance and therefore can
>     		 * move the instance around on the list at-will.
>     		 */
>     
>     A few drivers do not do this because they mix the budget checks
>     with reading hardware state, resulting in crashes like the one
>     reported by takano@axe-inc.co.jp.
>     
>     BNX2 and TG3 are taken care of here, SKY2 fix is from Stephen
>     Hemminger.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
I am sorry for late reply.
I confirmed this patch fixes the kernel panic that I reported.
Thanks David and others.

Ryousei Takano
