From: David Miller <davem@davemloft.net>
Subject: Re: net/smsc911x: problems after commit 3ac3546e [Always wait for
 the chip to be ready]
Date: Mon, 12 Nov 2012 14:40:27 -0500 (EST)
Message-ID: <20121112.144027.1074374601388950128.davem@davemloft.net>
References: <20121106.123623.676046673605774326.davem@davemloft.net>
	<20121108.015754.967579869456342727.davem@davemloft.net>
	<20121112100445.GA12511@patelk@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve@shawell.net, linus.walleij@linaro.org,
	robert.marklund@stericsson.com, netdev@vger.kernel.org
To: kamlakant.patel@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021Ab2KLTk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 14:40:29 -0500
In-Reply-To: <20121112100445.GA12511@patelk@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
Date: Mon, 12 Nov 2012 15:34:46 +0530

> On Thu, Nov 08, 2012 at 01:57:54AM -0500, David Miller wrote:
>> From: "Kamlakant Patel" <kamlakant.patel@broadcom.com>
>> Date: Thu, 8 Nov 2012 12:16:28 +0530
>> 
>> > smsc driver is disabled in our bootloader and it is not changing the
>> > state of the smsc registers at any stage, so it is not a bootloader
>> > issue.
>> 
>> What puts that chip into a non-default byte swapping mode then?
> 
> This is a property of the XLP GBU (IO bus flash like devices). A 32-bit
> read/write will be split into two 16-bit operations, and when the XLP is
> in big-endian mode, we get the lower 16-bit ends up in bits 31-16 and the
> upper 16-bit in bits 15-0.
> 
> The code before commit 3ac3546e worked because the driver saw that the registers
> are word swapped (not byte swapped) and programmed the WORD_SWAP register
> first (before any other register operations).

Ok, fair enough.   Someone can resubmit the patch, and I'll apply it,
but I still very much dislike this situation.

Please make sure there is a very verbose comment added to the code,
and a similarly verbose commit message for the patch explaining
exactly how the chip gets into this state and why we have to solve
the problem this way.

Thanks.
