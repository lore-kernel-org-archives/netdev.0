From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] mlx4: mlx4_core failed to load
Date: Tue, 13 May 2014 12:32:17 -0400 (EDT)
Message-ID: <20140513.123217.22616774554500768.davem@davemloft.net>
References: <20140428183330.201681971@linux.vnet.ibm.com>
	<20140428.155900.1619506417111671946.davem@davemloft.net>
	<5372350E.7030100@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43339 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbaEMQcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 12:32:21 -0400
In-Reply-To: <5372350E.7030100@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol Soto <clsoto@linux.vnet.ibm.com>
Date: Tue, 13 May 2014 10:06:54 -0500

> 
> On 4/28/2014 2:59 PM, David Miller wrote:
>> From: clsoto@linux.vnet.ibm.com
>> Date: Mon, 28 Apr 2014 13:33:30 -0500
>>
>>> This is for a case where mlx4_core fails to load.
>> You cannot just will-nilly delete module parameters that you decide
>> you don't want to support any more.
>>
>> Once you add a module parameter, you are stuck with it forever once
>> it makes it into a released kernel.  It is a user visible interface.
>>
>> I'm not applying this patch, you have to actually fix the bug rather
>> then wholesale remove the facility altogether.
> 
> The problem here is that when use_prio argument is used then the
> number of reserved qps increase from 0x20000 to 0x90000. So when it
> goes to mlx4_bitmap_init the argument reserved_top becomes a lot
> bigger than argument num, because of this then the math to get the
> size for the kzalloc is very big. The argument num is the num of qps
> that the adapter supports so then this sounds to me like a bug that if
> we use the use_prio we can not have more qps reserved than the num qps
> that adapter supports. That is why I went to the path of removing the
> argument in this patch. Any other suggestion?

It is not my job to fix bugs in your driver.

But it is my job to make sure you do not break things that are
user visible, and that means you cannot delete module parameters
that are "too difficult to fix".

You should have considered more carefully the semantics of this
module option when it was added.
