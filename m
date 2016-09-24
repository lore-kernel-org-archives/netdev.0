From: David Miller <davem@davemloft.net>
Subject: Re: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 22:43:05 -0400 (EDT)
Message-ID: <20160923.224305.942077200829435690.davem@davemloft.net>
References: <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
        <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
        <0fe7a310-2d2f-4fca-d698-85d66122d91c@nelint.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, rmk+kernel@arm.linux.org.uk,
        fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
        otavio@ossystems.com.br, cjb.sw.nospam@gmail.com
To: eric@nelint.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756175AbcIXCnV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 22:43:21 -0400
In-Reply-To: <0fe7a310-2d2f-4fca-d698-85d66122d91c@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Nelson <eric@nelint.com>
Date: Fri, 23 Sep 2016 10:33:29 -0700

> Since the hardware requires longword alignment for its' DMA transfers,
> aligning the IP header will require a memcpy, right?

I wish hardware designers didn't do this.

There is no conflict between DMA alignment and properly offseting
the packet data by two bytes.

All hardware designers have to do is allow 2 padding bytes to be
emitted by the chip before the actual packet data.

Then the longword or whatever DMA transfer alignment is met
whilst still giving the necessary flexibility for where the
packet data lands.
