From: Eric Nelson <eric@nelint.com>
Subject: Re: Alignment issues with freescale FEC driver
Date: Sat, 24 Sep 2016 05:27:15 -0700
Message-ID: <78d1e5e1-30dd-e434-9656-2d2bab32956f@nelint.com>
References: <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
 <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
 <0fe7a310-2d2f-4fca-d698-85d66122d91c@nelint.com>
 <20160923.224305.942077200829435690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, rmk+kernel@arm.linux.org.uk,
        fugang.duan@nxp.com, troy.kisky@boundarydevices.com,
        otavio@ossystems.com.br, cjb.sw.nospam@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32977 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756266AbcIXM1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 08:27:17 -0400
Received: by mail-pa0-f41.google.com with SMTP id hm5so48383576pac.0
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 05:27:17 -0700 (PDT)
In-Reply-To: <20160923.224305.942077200829435690.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 09/23/2016 07:43 PM, David Miller wrote:
> From: Eric Nelson <eric@nelint.com>
> Date: Fri, 23 Sep 2016 10:33:29 -0700
> 
>> Since the hardware requires longword alignment for its' DMA transfers,
>> aligning the IP header will require a memcpy, right?
> 
> I wish hardware designers didn't do this.
> 
> There is no conflict between DMA alignment and properly offseting
> the packet data by two bytes.
> 
> All hardware designers have to do is allow 2 padding bytes to be
> emitted by the chip before the actual packet data.
> 

Andrew Lunn pointed out that the hardware does support this,
and I just pushed a patch for the vendor kernel to the meta-freescale
mailing list:

https://lists.yoctoproject.org/pipermail/meta-freescale/2016-September/019228.html

> Then the longword or whatever DMA transfer alignment is met
> whilst still giving the necessary flexibility for where the
> packet data lands.
> 

Right. A relatively small change fixes things right up.

Many thanks to Andrew for pointing this out and Russell for providing
the basis for my patch.

I'll re-work this for the up-stream kernel when I get out from
under a couple of unrelated things.
