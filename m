From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/3] net: irda: pxaficp_ir: use sched_clock() for
 time management
Date: Mon, 28 Sep 2015 22:33:10 -0700 (PDT)
Message-ID: <20150928.223310.709463014669733152.davem@davemloft.net>
References: <1443293360-16377-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53966 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbbI2FdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:33:10 -0400
In-Reply-To: <1443293360-16377-1-git-send-email-robert.jarzmik@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Sat, 26 Sep 2015 20:49:18 +0200

> Instead of using directly the OS timer through direct register access,
> use the standard sched_clock(), which will end up in OSCR reading
> anyway.
> 
> This is a first step for direct access register removal and machine
> specific code removal from this driver.
> 
> This commit changes the behavior, as previously the minimum turnaround
> time was counted in 76ns steps, while with this patch it is counted in
> microsecond steps. The strictly equal formula would have been :
> 	    while ((sched_clock() - si->last_clk) * 76 < mtt)
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> ---
> Since v2: fixed clock calculation as pointed out by David

Applied to net-next.
