From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Fri, 17 Apr 2009 02:08:41 -0700 (PDT)
Message-ID: <20090417.020841.21679845.davem@davemloft.net>
References: <20090416112435.0b779859@surf>
	<20090417.013450.02738760.davem@davemloft.net>
	<20090417110703.781f8a0e@hskinnemoen-d830>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	michael@free-electrons.com
To: haavard.skinnemoen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56099
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752492AbZDQJIt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 05:08:49 -0400
In-Reply-To: <20090417110703.781f8a0e@hskinnemoen-d830>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Date: Fri, 17 Apr 2009 11:07:03 +0200

> David Miller wrote:
>> And in response to this Haavard explained the potential deadlock
>> (sorry I deleted that email) and suggested to use local_irq_save()
>> 
>> But that won't work either, because it doesn't prevent the interrupt
>> handler from running on other cpus, it only prevents that on the
>> local cpu.
> 
> The interrupt handler takes bp->lock. Isn't that sufficient to prevent
> it from running on other cpus?

We don't necessarily hold bp->lock here, we could be called from
the netpoll code.  Another cpu could easily hold bp->lock and be
in the middle of the interrupt handler.

