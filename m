From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eth: altera: fix napi poll_list corruption
Date: Wed, 02 Sep 2015 22:32:54 -0700 (PDT)
Message-ID: <20150902.223254.456957929929322205.davem@davemloft.net>
References: <20150902.174929.153474872.nemoto@toshiba-tops.co.jp>
	<20150902.112500.2176991714061589322.davem@davemloft.net>
	<20150903.095257.116214212.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org
To: nemoto@toshiba-tops.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbbICFc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 01:32:58 -0400
In-Reply-To: <20150903.095257.116214212.nemoto@toshiba-tops.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Date: Thu, 3 Sep 2015 09:52:57 +0900

> On Wed, 2 Sep 2015 11:25:00 -0700, David Miller <davem@davemloft.net> wrote:
>> Two lines below this change you are disabling interrupts anyways,
>> so I would suggest just moving the spin_lock_irqsave() before the
>> napi_gro_flush() to fix this.
>> 
>> Many of the checks done by napi_complete_done() (invoked by
>> napi_complete()) are completely redundant in this context.  For
>> example, the direct __napi_complete() call is a really nice
>> optimization because we know we are on the poll list and therefore
>> it is not empty.
> 
> Thank you for your suggestion.
> 
> I think napi_gro_flush() can be called with irq enabled, so moving the
> spin_lock_irqsave() just before the __napi_complete() (or moving the
> __napi_complete() just after the spin_lock_irqsave()) would be better,
> right?

It should work, yes.
