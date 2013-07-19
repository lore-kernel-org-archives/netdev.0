From: David Miller <davem@davemloft.net>
Subject: Re: r8169: is the work queue is initialized at wrong place?
Date: Thu, 18 Jul 2013 20:16:04 -0700 (PDT)
Message-ID: <20130718.201604.1029725996842278443.davem@davemloft.net>
References: <5838023.rAHnY47tlv@al>
	<20130718215343.GA25075@electric-eye.fr.zoreil.com>
	<2387149.B9WVEQm2aY@al>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, nic_swsd@realtek.com
To: lekensteyn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933493Ab3GSDQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 23:16:07 -0400
In-Reply-To: <2387149.B9WVEQm2aY@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>
Date: Fri, 19 Jul 2013 00:41:57 +0200

> On Thursday 18 July 2013 23:53:43 Francois Romieu wrote:
>> Peter Wu <lekensteyn@gmail.com> :
>> [...]
>> 
>> > However, this queue is only initialized in rtl_open:
>> > 
>> > 6673         INIT_WORK(&tp->wk.work, rtl_task);
>> > 6674
>> > 6675         smp_mb();
>> > 
>> > Shouldn't this INIT_WORK be done in rtl_init_one ?
>> 
>> (or cancel_work_sync in rtl8169_close to reduce the scope)
> Will this also work with multiple adapters? I currently have an on-board chip 
> using the r8169 driver and a separate PCI card.

Francois's suggested fix will work just as equally, regardless of
number of adapters.
