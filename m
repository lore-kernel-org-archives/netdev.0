From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: core: Prevent from dereferencing null pointer
 when
Date: Mon, 24 Apr 2017 21:44:50 -0400 (EDT)
Message-ID: <20170424.214450.2215530406378773476.davem@davemloft.net>
References: <1492732760-25081-1-git-send-email-mhjungk@gmail.com>
        <20170424.120235.438297438450788048.davem@davemloft.net>
        <20170425010052.GA8717@fqdn.specialj.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: mhjungk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S979584AbdDYBoy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 21:44:54 -0400
In-Reply-To: <20170425010052.GA8717@fqdn.specialj.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Myungho Jung <mhjungk@gmail.com>
Date: Mon, 24 Apr 2017 18:00:52 -0700

> On Mon, Apr 24, 2017 at 12:02:35PM -0400, David Miller wrote:
>> From: Myungho Jung <mhjungk@gmail.com>
>> Date: Thu, 20 Apr 2017 16:59:20 -0700
>> 
>> > Added NULL check to make __dev_kfree_skb_irq consistent with kfree
>> > family of functions.
>> > 
>> > Link: https://bugzilla.kernel.org/show_bug.cgi?id=195289
>> > 
>> > Signed-off-by: Myungho Jung <mhjungk@gmail.com>
>> > ---
>> > Changes in v2:
>> >  - Correct category in subject
>> 
>> This subject line is an incomplete sentence.
>> 
>> This patch prevents dereferenccing a null pointer when "what"?
> 
> As it was reported on bugzilla, it would happen when plugging p54 usb device
> to RPi2. But, i'm not 100% sure that this patch will resolve the issue because
> the reporter didn't try my patch yet and I don't have the device to test.
> 
> And there might be some other places calling the function without checking
> null pointer. The thing is that only the function don't check null among
> kfree functions. So, I just hope this patch will prevent potential oops
> issues.

It doesn't check for a NULL pointer because it is almost exclusively
used in the interrupt paths where we know we have a non-NULL skb.
