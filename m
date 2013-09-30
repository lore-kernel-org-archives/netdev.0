From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] moxa: drop free_irq of devm_request_irq allocated irq
Date: Mon, 30 Sep 2013 14:55:26 -0400 (EDT)
Message-ID: <20130930.145526.2002275544537353463.davem@davemloft.net>
References: <CAPgLHd8YRP7kL_jNHi3J9jFn86f=Fv-AWWUY_aRGZQOgVTNPgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	jg1.han@samsung.com, jonas.jensen@gmail.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35280 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755812Ab3I3Sz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 14:55:29 -0400
In-Reply-To: <CAPgLHd8YRP7kL_jNHi3J9jFn86f=Fv-AWWUY_aRGZQOgVTNPgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 25 Sep 2013 15:33:29 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> irq allocated with devm_request_irq should not be freed using
> free_irq, because doing so causes a dangling pointer, and a
> subsequent double free.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

I think this is a dangerous change, if the IRQ fires after the point
of the existing free_irq() call it will try to dereference the net
device struct which will be free by the time the devm release code
runes.

I'm not applying this patch, sorry.
