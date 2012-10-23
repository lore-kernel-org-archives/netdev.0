From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/4] net/macb: fix truncate warnings
Date: Tue, 23 Oct 2012 04:48:29 -0400 (EDT)
Message-ID: <20121023.044829.1915412359769438159.davem@davemloft.net>
References: <1350931534-8416-1-git-send-email-manabian@gmail.com>
	<1350931534-8416-2-git-send-email-manabian@gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B705B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manabian@gmail.com, nicolas.ferre@atmel.com, hskinnemoen@gmail.com,
	egtvedt@samfundet.no, plagnioj@jcrosoft.com, bgat@billgatliff.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756945Ab2JWIsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 04:48:33 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B705B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Tue, 23 Oct 2012 09:21:11 +0100

>> When building macb on x86_64 the following warnings show up:
>>   drivers/net/ethernet/cadence/macb.c: In function macb_interrupt:
>>   drivers/net/ethernet/cadence/macb.c:556:4: warning: large integer implicitly truncated to unsigned type [-Woverflow]
> ...
>> -			macb_writel(bp, IDR, ~0UL);
>> +			macb_writel(bp, IDR, -1);
> 
> Seems wrong to fix an error with an unsigned value
> by using -1.

-1 is equally an unsigned value of all 1's and completely legitimate.
The correction being made here is one of size not signedness.
