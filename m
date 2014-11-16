From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/at91_ether: fix loading when macb is compiled as a
 module
Date: Sun, 16 Nov 2014 13:53:02 -0500 (EST)
Message-ID: <20141116.135302.1339801219762777528.davem@davemloft.net>
References: <1416161106-27498-1-git-send-email-gilles.chanteperdrix@xenomai.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: gilles.chanteperdrix@xenomai.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbaKPSxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 13:53:07 -0500
In-Reply-To: <1416161106-27498-1-git-send-email-gilles.chanteperdrix@xenomai.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
Date: Sun, 16 Nov 2014 19:05:06 +0100

> The at91_ether driver depends on symbols defined in the macb driver.
> 
> Currently, when compiling both at91_ether and macb as module, starting
> the at91_ether module fails, because the macb module can not be loaded
> with a macb interface.
> 
> Avoid this issue by getting the macb module initialization routine to
> always return 0, even when no macb device is detected.
> 
> Signed-off-by: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>

This is not acceptable, sorry.

This means the module stays in memory even if nobody has a real use
for it.

You'll need to find another solution, and I'll say in passing that this
was very poorly designed and that's why the problem exists.
