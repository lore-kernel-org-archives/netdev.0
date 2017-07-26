From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ftgmac100: return error in ftgmac100_alloc_rx_buf
Date: Tue, 25 Jul 2017 21:22:03 -0700 (PDT)
Message-ID: <20170725.212203.942836822088934965.davem@davemloft.net>
References: <20170725004901.13406-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
To: joel@jms.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39074 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdGZEWE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 00:22:04 -0400
In-Reply-To: <20170725004901.13406-1-joel@jms.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joel Stanley <joel@jms.id.au>
Date: Tue, 25 Jul 2017 10:19:01 +0930

> The error paths set err, but it's not returned.
> 
> I wondered if we should fix all of the callers to check the returned
> value, but Ben explains why the code is this way:
> 
>> Most call sites ignore it on purpose. There's nothing we can do if
>> we fail to get a buffer at interrupt time, so we point the buffer to
>> the scratch page so the HW doesn't DMA into lalaland and lose the
>> packet.
>>
>> The one call site that tests and can fail is the one used when brining
>> the interface up. If we fail to allocate at that point, we fail the
>> ifup. But as you noticed, I do have a bug not returning the error.
> 
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Signed-off-by: Joel Stanley <joel@jms.id.au>

Applied, thanks.
