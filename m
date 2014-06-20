From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net]tg3: Change nvram command timeout value to 50ms
Date: Thu, 19 Jun 2014 20:59:14 -0700 (PDT)
Message-ID: <20140619.205914.315182669039252761.davem@davemloft.net>
References: <1403141922-21768-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: prashant@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbaFTD7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 23:59:17 -0400
In-Reply-To: <1403141922-21768-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant@broadcom.com>
Date: Wed, 18 Jun 2014 18:38:42 -0700

> Commit 506724c463fcd63477a5e404728a980b71f80bb7 "tg3: Override clock,
> link aware and link idle mode during NVRAM dump" changed the timeout
> value for nvram command execution from 100ms to 1ms. But the 1ms
> timeout value was only sufficient for nvram read operations but not
> write operations for most of the devices supported by tg3 driver.
> This patch sets the MAX to 50ms. Also to avoid busy waiting for a long
> time, the driver will udelay for 1ms and msleep for the remaining time.
> 
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Please don't have this conditional type of busy waiting.

Perhaps use something like usleep_range() for every loop iteation.
