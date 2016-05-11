From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 3/4] net: w5100: increase TX timeout period
Date: Wed, 11 May 2016 19:49:01 -0400 (EDT)
Message-ID: <20160511.194901.2167534565947789386.davem@davemloft.net>
References: <1462948227-21276-1-git-send-email-akinobu.mita@gmail.com>
	<1462948227-21276-4-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, msink@permonline.ru
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbcEKXtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 19:49:03 -0400
In-Reply-To: <1462948227-21276-4-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Wed, 11 May 2016 15:30:26 +0900

> This increases TX timeout period from one second to 5 seconds which is
> default value defined in net/sched/sch_generic.c.
> 
> The one second timeout is too short for W5100 with SPI interface mode
> which doesn't support burst READ/WRITE processing in the SPI transfer.
> If the packet is transmitted while RX packets are being received at a
> very high rate, the TX transmittion work in the workqueue is delayed
> and the watchdog timer is expired.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

It would be just cleaner to just remove the assignment completely, and
let said net/sched/sch_generic.c code set the default for you.
