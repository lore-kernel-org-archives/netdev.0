From: David Miller <davem@davemloft.net>
Subject: Re: net/smsc911x: problems after commit 3ac3546e [Always wait for
 the chip to be ready]
Date: Tue, 06 Nov 2012 12:36:23 -0500 (EST)
Message-ID: <20121106.123623.676046673605774326.davem@davemloft.net>
References: <264CB35B0DEC34409EE4134DB2E2DA569AA2DB@IRVEXCHMB15.corp.ad.broadcom.com>
	<CAKh2mn7XsJjGxctHs5F3d+Av3GpeJW9veH5=S=Y2y_qGf33R4g@mail.gmail.com>
	<20121106054643.GB8634@patelk@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve@shawell.net, linus.walleij@linaro.org,
	robert.marklund@stericsson.com, netdev@vger.kernel.org
To: kamlakant.patel@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab2KFRg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 12:36:27 -0500
In-Reply-To: <20121106054643.GB8634@patelk@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
Date: Tue, 6 Nov 2012 11:16:44 +0530

> The issue is that the logic of the commit 3ac3546e does not work if
> WORD_SWAP is needed. So we have to either revert that commit or add
> logic to check for swapped register if we read PMT_CTRL before
> programming WORD_SWAP.

I understand the problem.

You program the device into a state the driver is not expecting,
you have to therefore undo that before transferring control to
the kernel.

I accept no other solution, testing random reserved bits is
bogus beyond belief.
