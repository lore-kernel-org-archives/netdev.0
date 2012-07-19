From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: netpoll support
Date: Wed, 18 Jul 2012 20:24:31 -0700 (PDT)
Message-ID: <20120718.202431.2078849403941565725.davem@davemloft.net>
References: <18143736.brt1iGhlQ1@al>
	<20120718.094524.264223189588300582.davem@davemloft.net>
	<20120719015637.M13815@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40935 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852Ab2GSDYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 23:24:32 -0400
In-Reply-To: <20120719015637.M13815@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Thu, 19 Jul 2012 10:00:10 +0800

> On Wed, 18 Jul 2012 09:45:24 -0700 (PDT), David Miller wrote
>> From: Lekensteyn <lekensteyn@gmail.com>
>> Date: Tue, 17 Jul 2012 18:29:34 +0200
>> 
>> > From: Peter Wu <lekensteyn@gmail.com>
>> > 
>> > This patch adds the netpoll function to support netconsole. Tested and works
>> > fine on my "JMC250 PCI Express Gigabit Ethernet Controller" (PCI ID 0250).
>> > 
>> > Signed-off-by: Peter Wu <lekensteyn@gmail.com>
>> 
>> Applied to net-next
>> 
>> I really wonder if this driver works on SMP systems at all.
> Hi davem:
> 
> I wrote/tested this driver on SMP system at very beginning.
> In face some of the design was aimed for SMP systems.
> Is there any obvious bug or something I should be aware of?

Well, you do no locking in your IRQ handler.

So how can you be sure in jme_free_irq() during jme_close() that the
handler is not running on some cpu somewhere?

That's why drivers like drivers/net/ethernet/broadcom/tg3.c have
a function like tg3_irq_quiesce(), to guarentee that no code path
is executing in the interrupt handler.
