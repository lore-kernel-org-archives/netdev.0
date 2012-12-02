From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/17] ATM fixes for pppoatm/br2684
Date: Sat, 01 Dec 2012 20:49:06 -0500 (EST)
Message-ID: <20121201.204906.1703696018528746748.davem@davemloft.net>
References: <20121201.114440.331740099591161757.davem@davemloft.net>
	<1354383226.21562.351.camel@shinybook.infradead.org>
	<1354408847.21562.365.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil,
	krzysiek@podlesie.net
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab2LBBtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 20:49:08 -0500
In-Reply-To: <1354408847.21562.365.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 02 Dec 2012 00:40:47 +0000

> On Sat, 2012-12-01 at 17:33 +0000, David Woodhouse wrote:
>> 
>> Very glad I added the BUILD_BUG_ON on the cb struct size now. Perhaps
>> there should be a generic helper for that? Something like
>>  skb_cb_cast(struct foo_cb, skb) could do it automatically...?
> 
> Something like this, perhaps? Using skb_cast_cb() would then make it
> fairly much impossible to accidentally overflow the size of the skb cb.

I actually prefer what we do now, which is do the BUILD_BUG_ON()
once in the subsystem specific code, usually the initializer.

It's part of creating a new SKB cb, adding that assertion somewhere.
